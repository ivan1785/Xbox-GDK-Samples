  ![](./media/image1.png)

#   DXR 삼각형 샘플

*\* 이 샘플은 2019년 11월 Scarlett GXDK와 호환됩니다.*

# 설명

이 샘플에서는 DXR API를 사용하는 기본적인 방법을 보여 줍니다. 이 샘플은
RTPSO(레이트레이싱 파이프라인 상태 개체), 셰이더 테이블 및 최상위/최하위
수준 가속 구조를 만듭니다. 또한 광선 생성, 가장 근접한 적중, 임의 적중
및 누락 셰이더를 비롯하여 최하위 수준 가속 구조 인스턴스화 방법도 보여
줍니다.

![](./media/image3.png)

# 샘플 빌드

이 샘플은 Project Scarlett만 지원합니다.

*자세한 내용은 GDK 문서에서* 샘플 실행하기*를 참조하세요.*

# 샘플 사용

클래식 \'SimpleTriangle\'을 레이트레이싱 시대로 가져오면 구성 가능한
수의 삼각형이 화면을 가로질러 펼쳐집니다. 키보드/게임 패드에서 A 키를
누르면 임의 적중 셰이더 설정/해제가 토글되며, 각 삼각형에 구멍을 뚫으면
뒤에 있는 삼각형이 보입니다.

# 컨트롤

| 작업                         |  게임패드         |  키보드            |
|------------------------------|------------------|-------------------|
| 임의 적중 셰이더 토글        |  A                |  A                 |
| 삼각형 수 늘리기             |  D-패드 위쪽      |  \+                |
| 삼각형 수 줄이기             |  D-패드 아래쪽    |  \-                |
| 구멍 크기 늘리기             |  오른쪽 트리거    |  W                 |
| 구멍 크기 줄이기             |  왼쪽 트리거      |  S                 |
| 종료                         |  보기 단추        |  Esc               |

# 구현 참고 사항

이 샘플은 먼저 \'CreateStateObject\' API를 사용하여 RTPSO(레이트레이싱
파이프라인 상태 개체)를 만듭니다. RTPSO에는 가장 근접한 적중 셰이더 및
임의 적중 셰이더로 구성되는 하나의 적중 그룹이 있습니다. 재귀 수준 및
광선 페이로드 크기 등의 다른 구성 속성도 지정됩니다.

BLAS(최하위 수준 가속 구조)는 단일 삼각형으로 구성되며, 현재 선택한
삼각형 수에 따라 TLAS(최상위 가속 구조)로 1\~10번 인스턴스화됩니다. 각
인스턴스에는 장면에서의 고유한 위치와 크기가 지정됩니다. 기본적으로
TLAS와 BLAS 중 하나를 가져오려는 경우, PIX 캡처에 표시되는 순서대로 모든
프레임에서 둘 다 빌드됩니다. 그러나 출시용 타이틀에서는 일반적으로 모든
프레임에서 TLAS를 다시 빌드하고 장기간 BLAS를 재사용할 수 있습니다.

광선 생성 셰이더는 Z축을 따라 간단한 직교 투영을 설정하고, DispatchRays
호출에서 시작되는 스레드당 단일 광선을 발생시킵니다.

모든 삼각형을 누락하고 UAV에 검은색을 쓰는 누락 셰이더가 모든 광선에
대해 호출됩니다(DispatchRays 호출 전에 UAV를 미리 검은색으로 나타내는
대신 이 작업이 수행됨).

가장 근접한 적중 셰이더는 무게중심 좌표를 계산하고 해당 좌표를 픽셀의
마지막 색으로 사용합니다.

임의 적중 셰이더는 무게중심 좌표 공간에서 삼각형의 중심(0.333, 0.333,
0.333)까지의 단순 거리를 계산하고, 이 거리가 공차보다 작으면 적중을
무시하도록 요청합니다. 그러면 광선은 해당 삼각형을 통과하도록 허용되고,
z축을 따라 다른 삼각형을 적중할 수 있습니다.

# 업데이트 기록

2019년 11월 1일 -- 샘플 만들기

# 개인정보처리방침

샘플을 컴파일하고 실행할 때 샘플의 사용을 추적하는 데 도움이 되도록 샘플
실행 파일의 파일 이름이 Microsoft에 전송됩니다. 이 데이터 수집을
옵트아웃하려면 Main.cpp에서 \"샘플 사용 원격 분석\"이라고 레이블이
지정된 코드 블록을 제거할 수 있습니다.

Microsoft의 일반 개인정보취급방침에 대한 자세한 내용은 [Microsoft
개인정보처리방침](https://privacy.microsoft.com/en-us/privacystatement/)을
참조하세요.
