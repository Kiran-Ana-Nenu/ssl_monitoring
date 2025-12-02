import os, requests
SLACK_WEBHOOK = os.getenv('SLACK_WEBHOOK_URL')
def send_slack_message(text: str):
    if not SLACK_WEBHOOK:
        return
    try:
        requests.post(SLACK_WEBHOOK, json={'text': text}, timeout=5)
    except Exception:
        pass
