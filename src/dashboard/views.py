from django.shortcuts import render, get_object_or_404
from django.contrib.auth.decorators import login_required
from django.http import JsonResponse
from monitoring.models import UserDomain
from monitoring.tasks import check_domain_certificate
@login_required
def index(request):
    domains = request.user.domains.all().select_related('user')
    return render(request, 'dashboard/index.html', {'domains': domains})
@login_required
def domain_row(request, domain_id):
    domain = get_object_or_404(UserDomain, pk=domain_id, user=request.user)
    return render(request, 'dashboard/_domain_row.html', {'d': domain})
@login_required
def trigger_check_now(request, domain_id):
    domain = get_object_or_404(UserDomain, pk=domain_id, user=request.user)
    domain.is_check_in_progress = True
    domain.save(update_fields=['is_check_in_progress'])
    result = check_domain_certificate.delay(domain.id)
    return JsonResponse({'task_id': result.id, 'domain_id': domain.id})
