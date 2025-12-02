from django.db import models
from django.contrib.auth import get_user_model
from django.utils import timezone
User = get_user_model()
class AuditMixin(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    class Meta:
        abstract = True
class UserDomain(AuditMixin):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='domains')
    domain_name = models.CharField(max_length=253, db_index=True)
    last_check_date = models.DateTimeField(null=True, blank=True)
    certificate_grade = models.CharField(max_length=2, blank=True)
    expiry_date = models.DateTimeField(null=True, blank=True)
    check_status_message = models.TextField(blank=True)
    is_check_in_progress = models.BooleanField(default=False)
    class Meta:
        unique_together = ('user','domain_name')
        ordering = ['expiry_date']
    def __str__(self):
        return f"{self.domain_name} ({self.user})"
class CertificateCheckResult(AuditMixin):
    domain = models.ForeignKey(UserDomain, on_delete=models.CASCADE, related_name='check_results')
    checked_at = models.DateTimeField(default=timezone.now)
    grade = models.CharField(max_length=2)
    days_remaining = models.IntegerField()
    is_successful = models.BooleanField(default=True)
    raw_message = models.TextField(blank=True)
    class Meta:
        ordering = ['-checked_at']
