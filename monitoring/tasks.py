import socket, ssl
from datetime import datetime, timezone
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from celery import shared_task
from django.utils import timezone as dj_tz
from .models import UserDomain, CertificateCheckResult
from notifications.services import notify_critical_if_needed
GRADE_RULES = [
    ('A', lambda days: days > 90),
    ('B', lambda days: 31 <= days <= 90),
    ('F', lambda days: days <= 30),
]
def grade_for_days(days_remaining: int) -> str:
    for grade, cond in GRADE_RULES:
        if cond(days_remaining):
            return grade
    return 'F'
def fetch_cert(hostname: str, port: int = 443, timeout: int = 10):
    context = ssl.create_default_context()
    with socket.create_connection((hostname, port), timeout=timeout) as sock:
        with context.wrap_socket(sock, server_hostname=hostname) as ssock:
            der_cert = ssock.getpeercert(binary_form=True)
            cert = x509.load_der_x509_certificate(der_cert, default_backend())
            return cert
@shared_task(bind=True, acks_late=True)
def check_domain_certificate(self, domain_id: int):
    try:
        domain = UserDomain.objects.get(pk=domain_id)
    except UserDomain.DoesNotExist:
        return {'status':'domain_not_found','domain_id':domain_id}
    domain.is_check_in_progress = True
    domain.save(update_fields=['is_check_in_progress'])
    try:
        cert = fetch_cert(domain.domain_name)
        not_after = cert.not_valid_after
        if not_after.tzinfo is None:
            not_after = not_after.replace(tzinfo=timezone.utc)
        now = datetime.now(timezone.utc)
        delta = not_after - now
        days_remaining = max(0, delta.days)
        grade = grade_for_days(days_remaining)
        domain.last_check_date = dj_tz.now()
        domain.certificate_grade = grade
        domain.expiry_date = not_after
        domain.check_status_message = 'OK'
        domain.is_check_in_progress = False
        domain.save()
        CertificateCheckResult.objects.create(
            domain=domain,
            checked_at=dj_tz.now(),
            grade=grade,
            days_remaining=days_remaining,
            is_successful=True,
            raw_message=f"Issuer: {cert.issuer.rfc4514_string()}"
        )
        notify_critical_if_needed(domain, days_remaining, grade)
        return {'status':'ok','domain':domain.domain_name,'days_remaining':days_remaining,'grade':grade}
    except Exception as exc:
        domain.last_check_date = dj_tz.now()
        domain.check_status_message = f"Error: {str(exc)}"
        domain.is_check_in_progress = False
        domain.save()
        CertificateCheckResult.objects.create(
            domain=domain,
            checked_at=dj_tz.now(),
            grade='ERR',
            days_remaining=0,
            is_successful=False,
            raw_message=str(exc)
        )
        return {'status':'error','error':str(exc),'domain':domain.domain_name}
@shared_task
def bulk_check_all_domains():
    from .models import UserDomain
    domains = UserDomain.objects.all().values_list('id', flat=True)
    for did in domains:
        check_domain_certificate.delay(did)
