enum CoachingStyle {
  strict('따끔하게', '엄격하고 직설적인 조언'),
  kind('친절하게', '부드럽고 격려적인 조언'), 
  friendly('친구처럼', '친근하고 편안한 조언'),
  motivational('동기부여', '열정적이고 격려하는 조언'),
  analytical('분석적으로', '데이터 기반의 객관적 조언');

  const CoachingStyle(this.displayName, this.description);
  
  final String displayName;
  final String description;
}