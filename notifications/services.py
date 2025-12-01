import os, requests
from django.core.mail import send_mail
SLACK_WEBHOOK = os.getenv('SLACK_WEBHOOK_URL')
def send_email(subject: str, message: str, recipients: list):
    send_mail(subject, message, None, recipients, fail_silently=False)
def send_slack_message(text: str):
    if not SLACK_WEBHOOK:
        return
    payload = {'text': text}
    try:
        requests.post(SLACK_WEBHOOK, json=payload, timeout=5)
    except Exception:
        pass
def notify_critical_if_needed(domain, days_remaining: int, grade: str):
    if grade == 'F' or days_remaining <= 30:
        subject = f"🔴 SSL Expiry Alert: {domain.domain_name} ({days_remaining} days)"
        msg = f"Domain {domain.domain_name} has {days_remaining} days left before certificate expiry. Grade: {grade}."
        try:
            send_email(subject, msg, [domain.user.email])
        except Exception:
            pass
        try:
            send_slack_message(msg)
        except Exception:
            pass
