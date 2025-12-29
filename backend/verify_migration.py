"""
마이그레이션 결과 검증 스크립트
"""
import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from apps.grievances.models import Area, Grievance
from apps.users.models import CustomUser

print("=" * 60)
print("마이그레이션 결과 검증")
print("=" * 60)

# 1. Area 테이블 확인
print("\n1. Area 테이블 확인:")
area_count = Area.objects.count()
print(f"   총 Area 개수: {area_count}개 (예상: 26개)")

if area_count > 0:
    print("\n   처음 5개 Area:")
    for area in Area.objects.all()[:5]:
        print(f"     - {area.name} (중심좌표: {area.center_point})")

    mijidung = Area.objects.filter(name='미지정').first()
    if mijidung:
        print(f"\n   [OK] '미지정' Area 존재: {mijidung.name}")
    else:
        print("\n   [ERROR] '미지정' Area 없음")

# 2. CustomUser nickname 확인
print("\n2. CustomUser nickname 확인:")
user_count = CustomUser.objects.count()
users_with_nickname = CustomUser.objects.exclude(nickname='').count()
print(f"   총 사용자: {user_count}명")
print(f"   nickname 있는 사용자: {users_with_nickname}명")

if user_count > 0:
    print("\n   처음 3명의 사용자:")
    for user in CustomUser.objects.all()[:3]:
        print(f"     - {user.email}: nickname='{user.nickname}', role={user.role}")

# 3. Grievance.area 확인
print("\n3. Grievance.area 확인:")
grievance_count = Grievance.objects.count()
grievances_with_area = Grievance.objects.filter(area__isnull=False).count()
print(f"   총 민원: {grievance_count}개")
print(f"   area 있는 민원: {grievances_with_area}개")

if grievance_count > 0:
    print("\n   처음 3개 민원:")
    for grievance in Grievance.objects.all()[:3]:
        area_name = grievance.area.name if grievance.area else 'NULL'
        print(f"     - {grievance.title[:30]}: area={area_name}, visibility={grievance.visibility}")

# 4. 민원 구역별 통계
print("\n4. 민원 구역별 통계:")
area_stats = {}
for grievance in Grievance.objects.select_related('area'):
    area_name = grievance.area.name if grievance.area else 'NULL'
    area_stats[area_name] = area_stats.get(area_name, 0) + 1

for area_name, count in sorted(area_stats.items(), key=lambda x: -x[1])[:5]:
    print(f"   - {area_name}: {count}개")

print("\n" + "=" * 60)
if area_count == 26 and users_with_nickname == user_count and grievances_with_area == grievance_count:
    print("[SUCCESS] 모든 마이그레이션이 성공적으로 완료되었습니다!")
else:
    print("[WARNING] 일부 데이터 확인 필요")
    if area_count != 26:
        print(f"   - Area 개수 불일치: {area_count} (예상: 26)")
    if users_with_nickname != user_count:
        print(f"   - nickname 없는 사용자: {user_count - users_with_nickname}명")
    if grievances_with_area != grievance_count:
        print(f"   - area 없는 민원: {grievance_count - grievances_with_area}개")
print("=" * 60)
