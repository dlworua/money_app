class BusinessQuizData {
  // 경영 분야 (240문제)
  // 기초: 96문제, 중급: 96문제, 고급: 48문제
  static final List<Map<String, dynamic>> _businessQuestions = [
    // === 기초 난이도 (96문제) ===
    {
      'question': '기업의 주요 목적은 무엇인가요?',
      'options': ['사회봉사', '이윤추구', '환경보호', '문화발전'],
      'correct': 1,
      'explanation': '기업의 주요 목적은 이윤을 추구하여 지속적으로 성장하고 발전하는 것입니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '마케팅 4P에 포함되지 않는 것은?',
      'options': ['Product', 'Price', 'People', 'Place'],
      'correct': 2,
      'explanation': '마케팅 믹스 4P는 Product, Price, Place, Promotion입니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '최고경영자를 의미하는 직책은?',
      'options': ['CFO', 'CEO', 'CTO', 'CMO'],
      'correct': 1,
      'explanation': 'CEO(Chief Executive Officer)는 최고경영자를 의미합니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '소비자에게 제품의 정체성과 가치를 전달하는 것은?',
      'options': ['포장', '브랜드', '광고', '가격'],
      'correct': 1,
      'explanation': '브랜드는 소비자에게 제품의 정체성과 가치를 전달하는 중요한 역할을 합니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '재구매율 증가와 긍정적 구전효과를 얻을 수 있는 요소는?',
      'options': ['저가정책', '고객만족도', '광고비', '직원수'],
      'correct': 1,
      'explanation': '고객 만족도가 높으면 재구매율이 증가하고 긍정적인 구전효과를 얻을 수 있습니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '조직에서 의사소통이 중요한 이유는?',
      'options': ['시간 낭비', '업무 효율성 향상', '비용 증가', '갈등 조장'],
      'correct': 1,
      'explanation': '원활한 의사소통은 업무 효율성을 높이고 조직 목표 달성에 기여합니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '리더십과 관리(management)의 차이는?',
      'options': ['같은 개념', '리더십은 변화 추진, 관리는 현상 유지', '관리가 더 중요', '리더십은 불필요'],
      'correct': 1,
      'explanation': '리더십은 변화를 추진하고 비전을 제시하며, 관리는 현재의 업무와 자원을 효율적으로 운영합니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '인적자원관리(HRM)의 주요 기능이 아닌 것은?',
      'options': ['채용', '교육', '평가', '회계'],
      'correct': 3,
      'explanation': 'HRM의 주요 기능은 채용, 교육, 평가, 보상, 퇴직관리 등입니다. 회계는 별도 영역입니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '기업의 사회적 책임(CSR)이란?',
      'options': ['단순 이익 추구', '사회와 환경에 대한 책임', '정부 규제 준수만', '주주 이익만 고려'],
      'correct': 1,
      'explanation': 'CSR은 기업이 경제적 이익뿐만 아니라 사회와 환경에 대한 책임도 다하는 것입니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '경쟁우위란?',
      'options': ['높은 가격', '경쟁사보다 우수한 가치 제공', '많은 직원', '큰 사무실'],
      'correct': 1,
      'explanation': '경쟁우위는 경쟁사 대비 고객에게 더 우수한 가치를 제공할 수 있는 능력입니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '목표관리(MBO)의 핵심은?',
      'options': ['상사의 일방적 지시', '구체적이고 측정 가능한 목표 설정', '처벌 중심 관리', '무목표 경영'],
      'correct': 1,
      'explanation': 'MBO는 구체적이고 측정 가능한 목표를 설정하고 성과를 관리하는 경영기법입니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '팀워크의 장점은?',
      'options': ['개인 성과만 중시', '집단사고', '시너지 효과', '책임 회피'],
      'correct': 2,
      'explanation': '좋은 팀워크는 개인의 능력을 합친 것보다 더 큰 시너지 효과를 창출합니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '고객 세분화의 목적은?',
      'options': ['고객 차별', '효과적인 마케팅 전략 수립', '가격 인상', '서비스 축소'],
      'correct': 1,
      'explanation': '고객 세분화를 통해 각 고객 그룹의 특성에 맞는 맞춤형 마케팅 전략을 수립할 수 있습니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '창업시 가장 먼저 해야 할 일은?',
      'options': ['사무실 임대', '사업계획서 작성', '직원 채용', '광고 시작'],
      'correct': 1,
      'explanation': '창업시에는 사업 아이디어를 구체화하고 실현 가능성을 검토하는 사업계획서 작성이 우선입니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    {
      'question': '품질관리의 중요성은?',
      'options': ['비용만 증가', '고객 만족과 경쟁력 향상', '불필요한 과정', '시간 낭비'],
      'correct': 1,
      'explanation': '품질관리를 통해 고객 만족도를 높이고 시장에서의 경쟁력을 향상시킬 수 있습니다.',
      'category': '경영',
      'difficulty': '기초',
    },
    // ... 기초 문제를 총 96개까지 계속 추가

    // === 중급 난이도 (96문제) ===
    {
      'question': 'SWOT 분석에서 S는 무엇을 의미하나요?',
      'options': ['Strategy', 'Strength', 'System', 'Structure'],
      'correct': 1,
      'explanation': 'SWOT에서 S는 Strength(강점)을 의미합니다. W는 Weakness, O는 Opportunities, T는 Threats입니다.',
      'category': '경영',
      'difficulty': '중급',
    },
    {
      'question': '포터의 5 Forces 모델에 포함되지 않는 것은?',
      'options': ['기존 경쟁업체', '신규 진입자', '정부 규제', '대체재'],
      'correct': 2,
      'explanation': '포터의 5 Forces는 기존 경쟁업체, 신규 진입자, 대체재, 공급업체, 구매자의 협상력입니다.',
      'category': '경영',
      'difficulty': '중급',
    },
    {
      'question': 'BCG 매트릭스에서 Cash Cow의 특징은?',
      'options': ['높은 성장률, 높은 시장점유율', '낮은 성장률, 높은 시장점유율', '높은 성장률, 낮은 시장점유율', '낮은 성장률, 낮은 시장점유율'],
      'correct': 1,
      'explanation': 'Cash Cow는 낮은 시장 성장률을 가지지만 높은 시장점유율을 유지하여 안정적인 현금을 창출합니다.',
      'category': '경영',
      'difficulty': '중급',
    },
    {
      'question': '린 스타트업(Lean Startup)의 핵심 개념은?',
      'options': ['대규모 투자', 'MVP와 빠른 피드백', '완벽한 제품 개발', '장기간 개발'],
      'correct': 1,
      'explanation': '린 스타트업은 MVP(최소기능제품)를 통해 빠르게 시장 피드백을 받아 제품을 개선하는 방법론입니다.',
      'category': '경영',
      'difficulty': '중급',
    },
    {
      'question': '블루오션 전략이란?',
      'options': ['기존 시장에서의 경쟁', '새로운 시장 창출', '해양 사업', '블루칩 투자'],
      'correct': 1,
      'explanation': '블루오션 전략은 경쟁이 없는 새로운 시장 공간을 창출하여 경쟁을 무의미하게 만드는 전략입니다.',
      'category': '경영',
      'difficulty': '중급',
    },
    // ... 중급 문제를 총 96개까지 계속 추가

    // === 고급 난이도 (48문제) ===
    {
      'question': '동적 역량(Dynamic Capabilities)이론의 핵심은?',
      'options': ['정적 자원 활용', '변화하는 환경에 대한 적응 능력', '고정된 전략', '단순 모방'],
      'correct': 1,
      'explanation': '동적 역량은 변화하는 환경에서 조직의 자원과 역량을 재구성하여 경쟁우위를 유지하는 능력입니다.',
      'category': '경영',
      'difficulty': '고급',
    },
    {
      'question': '지식경영(Knowledge Management)에서 암묵지와 형식지의 변환 과정을 설명한 모델은?',
      'options': ['SWOT 모델', 'SECI 모델', '5 Forces 모델', 'BCG 매트릭스'],
      'correct': 1,
      'explanation': 'SECI 모델은 노나카와 다케우치가 제시한 지식 창조 과정으로 Socialization, Externalization, Combination, Internalization의 순환 과정입니다.',
      'category': '경영',
      'difficulty': '고급',
    },
    {
      'question': '거래비용이론(Transaction Cost Theory)에 따르면 기업의 경계는?',
      'options': ['정부가 결정', '거래비용을 최소화하는 지점', '무작위로 결정', '항상 확장'],
      'correct': 1,
      'explanation': '거래비용이론에 따르면 시장 거래비용과 조직 내부 관리비용을 비교하여 더 효율적인 방식을 선택합니다.',
      'category': '경영',
      'difficulty': '고급',
    },
    // ... 고급 문제를 총 48개까지 계속 추가
  ];

  static List<Map<String, dynamic>> getRandomQuestions(int count) {
    final shuffled = List<Map<String, dynamic>>.from(_businessQuestions)..shuffle();
    return shuffled.take(count).toList();
  }

  static List<Map<String, dynamic>> getQuestionsByDifficulty(String difficulty, int count) {
    final filtered = _businessQuestions.where((q) => q['difficulty'] == difficulty).toList();
    final shuffled = List<Map<String, dynamic>>.from(filtered)..shuffle();
    return shuffled.take(count).toList();
  }

  static List<Map<String, dynamic>> get allQuestions => _businessQuestions;
}