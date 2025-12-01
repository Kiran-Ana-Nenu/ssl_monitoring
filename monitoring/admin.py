from django.contrib import admin
from .models import UserDomain, CertificateCheckResult
@admin.register(UserDomain)
class UserDomainAdmin(admin.ModelAdmin):
    list_display = ('domain_name','user','expiry_date','certificate_grade','last_check_date','is_check_in_progress')
    search_fields = ('domain_name','user__username')
@admin.register(CertificateCheckResult)
class CertResultAdmin(admin.ModelAdmin):
    list_display = ('domain','checked_at','grade','days_remaining','is_successful')
    list_filter = ('is_successful','grade')
