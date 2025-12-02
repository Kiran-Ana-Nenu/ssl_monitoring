from celery import shared_task
from django.core.mail import send_mail
from django.contrib.auth import get_user_model
User = get_user_model()
@shared_task(queue='email')
def send_email_alert(user_id, domain_name, days_remaining):
    try:
        user = User.objects.get(pk=user_id)
        subject = f"🔴 SSL Expiry Alert: {domain_name} ({days_remaining} days)"
        message = f"Domain {domain_name} has {days_remaining} days left before certificate expiry."
        send_mail(subject, message, None, [user.email], fail_silently=False)
    except Exception:
        pass
