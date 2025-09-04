class VocabularyQuestion {
  final String korean;
  final String correctAnswer;
  final List<String> options;

  VocabularyQuestion({
    required this.korean,
    required this.correctAnswer,
    required this.options,
  });
}

class VocabularyData {
  // 최근에 사용된 단어들을 기록하는 정적 변수
  static final Set<String> _recentlyUsedQuestions = <String>{};
  
  static final List<VocabularyQuestion> allQuestions = [
    // 기본 일상 어휘
    VocabularyQuestion(
      korean: '식료품점',
      correctAnswer: 'Grocery Store',
      options: [
        'Grocery Store',
        'Shopping Mall',
        'Department Store',
        'Convenience Store',
      ],
    ),
    VocabularyQuestion(
      korean: '과일',
      correctAnswer: 'Fruit',
      options: ['Fruit', 'Vegetable', 'Snack', 'Dessert'],
    ),
    VocabularyQuestion(
      korean: '채소',
      correctAnswer: 'Vegetable',
      options: ['Vegetable', 'Fruit', 'Herb', 'Grain'],
    ),
    VocabularyQuestion(
      korean: '육류',
      correctAnswer: 'Meat',
      options: ['Meat', 'Seafood', 'Poultry', 'Dairy'],
    ),
    VocabularyQuestion(
      korean: '유제품',
      correctAnswer: 'Dairy',
      options: ['Dairy', 'Beverage', 'Protein', 'Grain'],
    ),
    VocabularyQuestion(
      korean: '빵',
      correctAnswer: 'Bread',
      options: ['Bread', 'Cake', 'Pastry', 'Cookie'],
    ),
    VocabularyQuestion(
      korean: '음료',
      correctAnswer: 'Beverage',
      options: ['Beverage', 'Food', 'Snack', 'Dessert'],
    ),
    VocabularyQuestion(
      korean: '간식',
      correctAnswer: 'Snack',
      options: ['Snack', 'Meal', 'Dessert', 'Appetizer'],
    ),
    VocabularyQuestion(
      korean: '냉동식품',
      correctAnswer: 'Frozen Food',
      options: ['Frozen Food', 'Fresh Food', 'Canned Food', 'Dry Food'],
    ),
    VocabularyQuestion(
      korean: '통조림',
      correctAnswer: 'Canned Food',
      options: ['Canned Food', 'Frozen Food', 'Fresh Food', 'Packaged Food'],
    ),

    // 외식 및 식당
    VocabularyQuestion(
      korean: '카페',
      correctAnswer: 'Cafe',
      options: ['Cafe', 'Restaurant', 'Bar', 'Bakery'],
    ),
    VocabularyQuestion(
      korean: '식당',
      correctAnswer: 'Restaurant',
      options: ['Restaurant', 'Cafe', 'Diner', 'Bistro'],
    ),
    VocabularyQuestion(
      korean: '패스트푸드',
      correctAnswer: 'Fast Food',
      options: ['Fast Food', 'Fine Dining', 'Casual Dining', 'Buffet'],
    ),
    VocabularyQuestion(
      korean: '디저트',
      correctAnswer: 'Dessert',
      options: ['Dessert', 'Appetizer', 'Main Course', 'Side Dish'],
    ),
    VocabularyQuestion(
      korean: '배달',
      correctAnswer: 'Delivery',
      options: ['Delivery', 'Pickup', 'Dine-in', 'Takeout'],
    ),
    VocabularyQuestion(
      korean: '포장',
      correctAnswer: 'Takeout',
      options: ['Takeout', 'Delivery', 'Dine-in', 'Buffet'],
    ),
    VocabularyQuestion(
      korean: '뷔페',
      correctAnswer: 'Buffet',
      options: ['Buffet', 'A la carte', 'Set Menu', 'Tasting Menu'],
    ),

    // 교통수단
    VocabularyQuestion(
      korean: '버스',
      correctAnswer: 'Bus',
      options: ['Bus', 'Train', 'Subway', 'Taxi'],
    ),
    VocabularyQuestion(
      korean: '정류장',
      correctAnswer: 'Bus Stop',
      options: ['Bus Stop', 'Station', 'Terminal', 'Platform'],
    ),
    VocabularyQuestion(
      korean: '지하철',
      correctAnswer: 'Subway',
      options: ['Subway', 'Train', 'Metro', 'Tram'],
    ),
    VocabularyQuestion(
      korean: '택시',
      correctAnswer: 'Taxi',
      options: ['Taxi', 'Bus', 'Car', 'Van'],
    ),
    VocabularyQuestion(
      korean: '기차',
      correctAnswer: 'Train',
      options: ['Train', 'Bus', 'Subway', 'Tram'],
    ),
    VocabularyQuestion(
      korean: '비행기',
      correctAnswer: 'Airplane',
      options: ['Airplane', 'Helicopter', 'Jet', 'Aircraft'],
    ),
    VocabularyQuestion(
      korean: '자동차',
      correctAnswer: 'Car',
      options: ['Car', 'Vehicle', 'Automobile', 'Truck'],
    ),
    VocabularyQuestion(
      korean: '오토바이',
      correctAnswer: 'Motorcycle',
      options: ['Motorcycle', 'Bicycle', 'Scooter', 'Motorbike'],
    ),
    VocabularyQuestion(
      korean: '자전거',
      correctAnswer: 'Bicycle',
      options: ['Bicycle', 'Motorcycle', 'Scooter', 'Bike'],
    ),
    VocabularyQuestion(
      korean: '주차장',
      correctAnswer: 'Parking Lot',
      options: ['Parking Lot', 'Garage', 'Driveway', 'Street'],
    ),

    // 쇼핑 및 구매
    VocabularyQuestion(
      korean: '쇼핑',
      correctAnswer: 'Shopping',
      options: ['Shopping', 'Buying', 'Purchasing', 'Browsing'],
    ),
    VocabularyQuestion(
      korean: '백화점',
      correctAnswer: 'Department Store',
      options: ['Department Store', 'Shopping Mall', 'Boutique', 'Market'],
    ),
    VocabularyQuestion(
      korean: '대형마트',
      correctAnswer: 'Supermarket',
      options: ['Supermarket', 'Grocery Store', 'Market', 'Store'],
    ),
    VocabularyQuestion(
      korean: '온라인쇼핑',
      correctAnswer: 'Online Shopping',
      options: [
        'Online Shopping',
        'E-commerce',
        'Digital Shopping',
        'Web Shopping',
      ],
    ),
    VocabularyQuestion(
      korean: '할인',
      correctAnswer: 'Discount',
      options: ['Discount', 'Sale', 'Promotion', 'Offer'],
    ),
    VocabularyQuestion(
      korean: '세일',
      correctAnswer: 'Sale',
      options: ['Sale', 'Discount', 'Promotion', 'Clearance'],
    ),
    VocabularyQuestion(
      korean: '쿠폰',
      correctAnswer: 'Coupon',
      options: ['Coupon', 'Voucher', 'Discount Code', 'Ticket'],
    ),
    VocabularyQuestion(
      korean: '영수증',
      correctAnswer: 'Receipt',
      options: ['Receipt', 'Invoice', 'Bill', 'Statement'],
    ),
    VocabularyQuestion(
      korean: '결제',
      correctAnswer: 'Payment',
      options: ['Payment', 'Transaction', 'Purchase', 'Settlement'],
    ),
    VocabularyQuestion(
      korean: '현금',
      correctAnswer: 'Cash',
      options: ['Cash', 'Money', 'Currency', 'Bills'],
    ),

    // 의료 및 건강
    VocabularyQuestion(
      korean: '의료비',
      correctAnswer: 'Medical Expenses',
      options: [
        'Medical Expenses',
        'Healthcare Cost',
        'Hospital Bill',
        'Treatment Cost',
      ],
    ),
    VocabularyQuestion(
      korean: '병원',
      correctAnswer: 'Hospital',
      options: ['Hospital', 'Clinic', 'Medical Center', 'Infirmary'],
    ),
    VocabularyQuestion(
      korean: '약국',
      correctAnswer: 'Pharmacy',
      options: ['Pharmacy', 'Drugstore', 'Apothecary', 'Dispensary'],
    ),
    VocabularyQuestion(
      korean: '의사',
      correctAnswer: 'Doctor',
      options: ['Doctor', 'Physician', 'Surgeon', 'Specialist'],
    ),
    VocabularyQuestion(
      korean: '약',
      correctAnswer: 'Medicine',
      options: ['Medicine', 'Medication', 'Drug', 'Prescription'],
    ),
    VocabularyQuestion(
      korean: '검진',
      correctAnswer: 'Medical Checkup',
      options: [
        'Medical Checkup',
        'Examination',
        'Health Screening',
        'Physical',
      ],
    ),
    VocabularyQuestion(
      korean: '수술',
      correctAnswer: 'Surgery',
      options: ['Surgery', 'Operation', 'Procedure', 'Treatment'],
    ),
    VocabularyQuestion(
      korean: '치과',
      correctAnswer: 'Dentist',
      options: ['Dentist', 'Dental Clinic', 'Orthodontist', 'Oral Surgeon'],
    ),
    VocabularyQuestion(
      korean: '응급실',
      correctAnswer: 'Emergency Room',
      options: ['Emergency Room', 'ICU', 'Operating Room', 'Waiting Room'],
    ),

    // 교육 및 학습
    VocabularyQuestion(
      korean: '교육',
      correctAnswer: 'Education',
      options: ['Education', 'Learning', 'Teaching', 'Training'],
    ),
    VocabularyQuestion(
      korean: '학교',
      correctAnswer: 'School',
      options: ['School', 'Academy', 'Institute', 'College'],
    ),
    VocabularyQuestion(
      korean: '대학교',
      correctAnswer: 'University',
      options: ['University', 'College', 'Institute', 'Academy'],
    ),
    VocabularyQuestion(
      korean: '도서관',
      correctAnswer: 'Library',
      options: ['Library', 'Archive', 'Study Hall', 'Reading Room'],
    ),
    VocabularyQuestion(
      korean: '책',
      correctAnswer: 'Book',
      options: ['Book', 'Novel', 'Textbook', 'Magazine'],
    ),
    VocabularyQuestion(
      korean: '학원',
      correctAnswer: 'Academy',
      options: ['Academy', 'Institute', 'School', 'Training Center'],
    ),
    VocabularyQuestion(
      korean: '과외',
      correctAnswer: 'Private Tutoring',
      options: ['Private Tutoring', 'Coaching', 'Mentoring', 'Teaching'],
    ),
    VocabularyQuestion(
      korean: '시험',
      correctAnswer: 'Exam',
      options: ['Exam', 'Test', 'Quiz', 'Assessment'],
    ),
    VocabularyQuestion(
      korean: '숙제',
      correctAnswer: 'Homework',
      options: ['Homework', 'Assignment', 'Task', 'Project'],
    ),
    VocabularyQuestion(
      korean: '수업',
      correctAnswer: 'Class',
      options: ['Class', 'Lesson', 'Course', 'Lecture'],
    ),

    // 여가 및 오락
    VocabularyQuestion(
      korean: '취미',
      correctAnswer: 'Hobby',
      options: ['Hobby', 'Interest', 'Pastime', 'Activity'],
    ),
    VocabularyQuestion(
      korean: '여가시간',
      correctAnswer: 'Leisure Time',
      options: ['Leisure Time', 'Free Time', 'Spare Time', 'Recreation'],
    ),
    VocabularyQuestion(
      korean: '영화',
      correctAnswer: 'Movie',
      options: ['Movie', 'Film', 'Cinema', 'Picture'],
    ),
    VocabularyQuestion(
      korean: '음악',
      correctAnswer: 'Music',
      options: ['Music', 'Song', 'Melody', 'Audio'],
    ),
    VocabularyQuestion(
      korean: '게임',
      correctAnswer: 'Game',
      options: ['Game', 'Sport', 'Play', 'Competition'],
    ),
    VocabularyQuestion(
      korean: '운동',
      correctAnswer: 'Exercise',
      options: ['Exercise', 'Workout', 'Sport', 'Activity'],
    ),
    VocabularyQuestion(
      korean: '헬스장',
      correctAnswer: 'Gym',
      options: ['Gym', 'Fitness Center', 'Health Club', 'Workout Room'],
    ),
    VocabularyQuestion(
      korean: '수영장',
      correctAnswer: 'Swimming Pool',
      options: ['Swimming Pool', 'Pool', 'Aquatic Center', 'Water Park'],
    ),
    VocabularyQuestion(
      korean: '공원',
      correctAnswer: 'Park',
      options: ['Park', 'Garden', 'Plaza', 'Square'],
    ),
    VocabularyQuestion(
      korean: '여행',
      correctAnswer: 'Travel',
      options: ['Travel', 'Trip', 'Journey', 'Vacation'],
    ),

    // 주거 및 생활
    VocabularyQuestion(
      korean: '집',
      correctAnswer: 'House',
      options: ['House', 'Home', 'Residence', 'Dwelling'],
    ),
    VocabularyQuestion(
      korean: '아파트',
      correctAnswer: 'Apartment',
      options: ['Apartment', 'Flat', 'Condo', 'Unit'],
    ),
    VocabularyQuestion(
      korean: '임대료',
      correctAnswer: 'Rent',
      options: ['Rent', 'Lease', 'Rental Fee', 'Monthly Payment'],
    ),
    VocabularyQuestion(
      korean: '전기요금',
      correctAnswer: 'Electricity Bill',
      options: [
        'Electricity Bill',
        'Power Bill',
        'Utility Bill',
        'Electric Fee',
      ],
    ),
    VocabularyQuestion(
      korean: '수도요금',
      correctAnswer: 'Water Bill',
      options: ['Water Bill', 'Utility Bill', 'Water Fee', 'Hydro Bill'],
    ),
    VocabularyQuestion(
      korean: '가스요금',
      correctAnswer: 'Gas Bill',
      options: ['Gas Bill', 'Utility Bill', 'Gas Fee', 'Heating Bill'],
    ),
    VocabularyQuestion(
      korean: '인터넷',
      correctAnswer: 'Internet',
      options: ['Internet', 'WiFi', 'Network', 'Connection'],
    ),
    VocabularyQuestion(
      korean: '가구',
      correctAnswer: 'Furniture',
      options: ['Furniture', 'Furnishing', 'Equipment', 'Appliance'],
    ),
    VocabularyQuestion(
      korean: '청소용품',
      correctAnswer: 'Cleaning Supplies',
      options: ['Cleaning Supplies', 'Detergent', 'Sanitizer', 'Disinfectant'],
    ),

    // 일상생활
    VocabularyQuestion(
      korean: '쓰레기',
      correctAnswer: 'Garbage',
      options: ['Garbage', 'Trash', 'Waste', 'Rubbish'],
    ),
    VocabularyQuestion(
      korean: '세탁',
      correctAnswer: 'Laundry',
      options: ['Laundry', 'Washing', 'Cleaning', 'Dry Cleaning'],
    ),
    VocabularyQuestion(
      korean: '우편물',
      correctAnswer: 'Mail',
      options: ['Mail', 'Post', 'Letter', 'Correspondence'],
    ),
    VocabularyQuestion(
      korean: '택배',
      correctAnswer: 'Package',
      options: ['Package', 'Parcel', 'Delivery', 'Shipment'],
    ),
    VocabularyQuestion(
      korean: '은행',
      correctAnswer: 'Bank',
      options: ['Bank', 'Financial Institution', 'Credit Union', 'Branch'],
    ),
    VocabularyQuestion(
      korean: '현금자동인출기',
      correctAnswer: 'ATM',
      options: ['ATM', 'Cash Machine', 'Banking Machine', 'Cash Dispenser'],
    ),
    VocabularyQuestion(
      korean: '휴대폰',
      correctAnswer: 'Mobile Phone',
      options: ['Mobile Phone', 'Cell Phone', 'Smartphone', 'Phone'],
    ),
    VocabularyQuestion(
      korean: '충전',
      correctAnswer: 'Charging',
      options: ['Charging', 'Recharging', 'Power Up', 'Battery Charge'],
    ),
    VocabularyQuestion(
      korean: '동전',
      correctAnswer: 'Coin',
      options: ['Coin', 'Change', 'Currency', 'Money'],
    ),
    VocabularyQuestion(
      korean: '지갑',
      correctAnswer: 'Wallet',
      options: ['Wallet', 'Purse', 'Billfold', 'Purse'],
    ),
    VocabularyQuestion(
      korean: '열쇠',
      correctAnswer: 'Key',
      options: ['Key', 'Keycard', 'Pass', 'Access Card'],
    ),
    VocabularyQuestion(
      korean: '우산',
      correctAnswer: 'Umbrella',
      options: ['Umbrella', 'Parasol', 'Canopy', 'Shade'],
    ),
    VocabularyQuestion(
      korean: '시계',
      correctAnswer: 'Watch',
      options: ['Watch', 'Clock', 'Timepiece', 'Timer'],
    ),
    VocabularyQuestion(
      korean: '안경',
      correctAnswer: 'Glasses',
      options: ['Glasses', 'Eyeglasses', 'Spectacles', 'Eyewear'],
    ),
    VocabularyQuestion(
      korean: '가방',
      correctAnswer: 'Bag',
      options: ['Bag', 'Backpack', 'Suitcase', 'Purse'],
    ),
    VocabularyQuestion(
      korean: '신발',
      correctAnswer: 'Shoes',
      options: ['Shoes', 'Footwear', 'Sneakers', 'Boots'],
    ),
    VocabularyQuestion(
      korean: '의류',
      correctAnswer: 'Clothing',
      options: ['Clothing', 'Clothes', 'Apparel', 'Garment'],
    ),
    VocabularyQuestion(
      korean: '선물',
      correctAnswer: 'Gift',
      options: ['Gift', 'Present', 'Surprise', 'Offering'],
    ),

    // 고급 어휘 - 비즈니스 및 전문용어
    VocabularyQuestion(
      korean: '계약서',
      correctAnswer: 'Contract',
      options: ['Contract', 'Agreement', 'Document', 'Certificate'],
    ),
    VocabularyQuestion(
      korean: '회의',
      correctAnswer: 'Meeting',
      options: ['Meeting', 'Conference', 'Discussion', 'Assembly'],
    ),
    VocabularyQuestion(
      korean: '프레젠테이션',
      correctAnswer: 'Presentation',
      options: ['Presentation', 'Speech', 'Report', 'Display'],
    ),
    VocabularyQuestion(
      korean: '협상',
      correctAnswer: 'Negotiation',
      options: ['Negotiation', 'Discussion', 'Bargaining', 'Agreement'],
    ),
    VocabularyQuestion(
      korean: '경영',
      correctAnswer: 'Management',
      options: ['Management', 'Administration', 'Leadership', 'Operation'],
    ),
    VocabularyQuestion(
      korean: '마케팅',
      correctAnswer: 'Marketing',
      options: ['Marketing', 'Advertising', 'Promotion', 'Sales'],
    ),
    VocabularyQuestion(
      korean: '투자',
      correctAnswer: 'Investment',
      options: ['Investment', 'Funding', 'Capital', 'Finance'],
    ),
    VocabularyQuestion(
      korean: '수익',
      correctAnswer: 'Profit',
      options: ['Profit', 'Revenue', 'Income', 'Earnings'],
    ),
    VocabularyQuestion(
      korean: '손실',
      correctAnswer: 'Loss',
      options: ['Loss', 'Deficit', 'Damage', 'Expense'],
    ),
    VocabularyQuestion(
      korean: '예산',
      correctAnswer: 'Budget',
      options: ['Budget', 'Finance', 'Fund', 'Allocation'],
    ),

    // 고급 어휘 - 학술 및 전문분야
    VocabularyQuestion(
      korean: '연구',
      correctAnswer: 'Research',
      options: ['Research', 'Study', 'Investigation', 'Analysis'],
    ),
    VocabularyQuestion(
      korean: '실험',
      correctAnswer: 'Experiment',
      options: ['Experiment', 'Test', 'Trial', 'Study'],
    ),
    VocabularyQuestion(
      korean: '이론',
      correctAnswer: 'Theory',
      options: ['Theory', 'Hypothesis', 'Concept', 'Principle'],
    ),
    VocabularyQuestion(
      korean: '가설',
      correctAnswer: 'Hypothesis',
      options: ['Hypothesis', 'Theory', 'Assumption', 'Premise'],
    ),
    VocabularyQuestion(
      korean: '분석',
      correctAnswer: 'Analysis',
      options: ['Analysis', 'Evaluation', 'Assessment', 'Review'],
    ),
    VocabularyQuestion(
      korean: '종합',
      correctAnswer: 'Synthesis',
      options: ['Synthesis', 'Combination', 'Integration', 'Merger'],
    ),
    VocabularyQuestion(
      korean: '논문',
      correctAnswer: 'Thesis',
      options: ['Thesis', 'Paper', 'Essay', 'Report'],
    ),
    VocabularyQuestion(
      korean: '학위',
      correctAnswer: 'Degree',
      options: ['Degree', 'Diploma', 'Certificate', 'Qualification'],
    ),
    VocabularyQuestion(
      korean: '장학금',
      correctAnswer: 'Scholarship',
      options: ['Scholarship', 'Grant', 'Fellowship', 'Award'],
    ),
    VocabularyQuestion(
      korean: '세미나',
      correctAnswer: 'Seminar',
      options: ['Seminar', 'Workshop', 'Conference', 'Symposium'],
    ),

    // 고급 어휘 - 기술 및 과학
    VocabularyQuestion(
      korean: '알고리즘',
      correctAnswer: 'Algorithm',
      options: ['Algorithm', 'Program', 'Formula', 'Method'],
    ),
    VocabularyQuestion(
      korean: '데이터베이스',
      correctAnswer: 'Database',
      options: ['Database', 'Storage', 'Archive', 'Repository'],
    ),
    VocabularyQuestion(
      korean: '소프트웨어',
      correctAnswer: 'Software',
      options: ['Software', 'Program', 'Application', 'System'],
    ),
    VocabularyQuestion(
      korean: '하드웨어',
      correctAnswer: 'Hardware',
      options: ['Hardware', 'Equipment', 'Device', 'Component'],
    ),
    VocabularyQuestion(
      korean: '네트워크',
      correctAnswer: 'Network',
      options: ['Network', 'System', 'Connection', 'Grid'],
    ),
    VocabularyQuestion(
      korean: '보안',
      correctAnswer: 'Security',
      options: ['Security', 'Safety', 'Protection', 'Defense'],
    ),
    VocabularyQuestion(
      korean: '암호화',
      correctAnswer: 'Encryption',
      options: ['Encryption', 'Coding', 'Security', 'Protection'],
    ),
    VocabularyQuestion(
      korean: '인공지능',
      correctAnswer: 'Artificial Intelligence',
      options: [
        'Artificial Intelligence',
        'Machine Learning',
        'Automation',
        'Technology',
      ],
    ),

    // 고급 어휘 - 사회 및 문화
    VocabularyQuestion(
      korean: '사회',
      correctAnswer: 'Society',
      options: ['Society', 'Community', 'Culture', 'Civilization'],
    ),
    VocabularyQuestion(
      korean: '문화',
      correctAnswer: 'Culture',
      options: ['Culture', 'Tradition', 'Heritage', 'Custom'],
    ),
    VocabularyQuestion(
      korean: '전통',
      correctAnswer: 'Tradition',
      options: ['Tradition', 'Custom', 'Heritage', 'Culture'],
    ),
    VocabularyQuestion(
      korean: '관습',
      correctAnswer: 'Custom',
      options: ['Custom', 'Tradition', 'Practice', 'Habit'],
    ),
    VocabularyQuestion(
      korean: '예술',
      correctAnswer: 'Art',
      options: ['Art', 'Culture', 'Creativity', 'Expression'],
    ),
    VocabularyQuestion(
      korean: '문학',
      correctAnswer: 'Literature',
      options: ['Literature', 'Writing', 'Poetry', 'Fiction'],
    ),
    VocabularyQuestion(
      korean: '철학',
      correctAnswer: 'Philosophy',
      options: ['Philosophy', 'Wisdom', 'Theory', 'Thought'],
    ),
    VocabularyQuestion(
      korean: '역사',
      correctAnswer: 'History',
      options: ['History', 'Past', 'Heritage', 'Chronicle'],
    ),

    // 고급 어휘 - 심리학 및 감정
    VocabularyQuestion(
      korean: '심리학',
      correctAnswer: 'Psychology',
      options: ['Psychology', 'Mental Health', 'Behavior', 'Mind'],
    ),
    VocabularyQuestion(
      korean: '감정',
      correctAnswer: 'Emotion',
      options: ['Emotion', 'Feeling', 'Mood', 'Sentiment'],
    ),
    VocabularyQuestion(
      korean: '동기',
      correctAnswer: 'Motivation',
      options: ['Motivation', 'Inspiration', 'Drive', 'Ambition'],
    ),
    VocabularyQuestion(
      korean: '성격',
      correctAnswer: 'Personality',
      options: ['Personality', 'Character', 'Nature', 'Temperament'],
    ),
    VocabularyQuestion(
      korean: '태도',
      correctAnswer: 'Attitude',
      options: ['Attitude', 'Behavior', 'Approach', 'Manner'],
    ),
    VocabularyQuestion(
      korean: '인식',
      correctAnswer: 'Perception',
      options: ['Perception', 'Recognition', 'Awareness', 'Understanding'],
    ),
    VocabularyQuestion(
      korean: '기억',
      correctAnswer: 'Memory',
      options: ['Memory', 'Recollection', 'Remembrance', 'Recall'],
    ),
    VocabularyQuestion(
      korean: '집중력',
      correctAnswer: 'Concentration',
      options: ['Concentration', 'Focus', 'Attention', 'Mindfulness'],
    ),

    // 고급 어휘 - 경제 및 금융
    VocabularyQuestion(
      korean: '경제',
      correctAnswer: 'Economy',
      options: ['Economy', 'Finance', 'Market', 'Business'],
    ),
    VocabularyQuestion(
      korean: '금융',
      correctAnswer: 'Finance',
      options: ['Finance', 'Banking', 'Economy', 'Money'],
    ),
    VocabularyQuestion(
      korean: '인플레이션',
      correctAnswer: 'Inflation',
      options: ['Inflation', 'Deflation', 'Economics', 'Price Rise'],
    ),
    VocabularyQuestion(
      korean: '증권',
      correctAnswer: 'Securities',
      options: ['Securities', 'Stocks', 'Bonds', 'Investment'],
    ),
    VocabularyQuestion(
      korean: '주식',
      correctAnswer: 'Stock',
      options: ['Stock', 'Share', 'Bond', 'Investment'],
    ),
    VocabularyQuestion(
      korean: '채권',
      correctAnswer: 'Bond',
      options: ['Bond', 'Stock', 'Security', 'Investment'],
    ),
    VocabularyQuestion(
      korean: '대출',
      correctAnswer: 'Loan',
      options: ['Loan', 'Credit', 'Mortgage', 'Debt'],
    ),
    VocabularyQuestion(
      korean: '저축',
      correctAnswer: 'Savings',
      options: ['Savings', 'Deposit', 'Investment', 'Fund'],
    ),
    VocabularyQuestion(
      korean: '보험',
      correctAnswer: 'Insurance',
      options: ['Insurance', 'Protection', 'Coverage', 'Policy'],
    ),
    VocabularyQuestion(
      korean: '세금',
      correctAnswer: 'Tax',
      options: ['Tax', 'Levy', 'Fee', 'Charge'],
    ),

    // 더 많은 일상 어휘
    VocabularyQuestion(
      korean: '일기예보',
      correctAnswer: 'Weather Forecast',
      options: ['Weather Forecast', 'Weather Report', 'Climate', 'Meteorology'],
    ),
    VocabularyQuestion(
      korean: '온도',
      correctAnswer: 'Temperature',
      options: ['Temperature', 'Heat', 'Weather', 'Climate'],
    ),
    VocabularyQuestion(
      korean: '습도',
      correctAnswer: 'Humidity',
      options: ['Humidity', 'Moisture', 'Dampness', 'Weather'],
    ),
    VocabularyQuestion(
      korean: '압력',
      correctAnswer: 'Pressure',
      options: ['Pressure', 'Force', 'Weight', 'Stress'],
    ),
    VocabularyQuestion(
      korean: '속도',
      correctAnswer: 'Speed',
      options: ['Speed', 'Velocity', 'Rate', 'Pace'],
    ),
    VocabularyQuestion(
      korean: '거리',
      correctAnswer: 'Distance',
      options: ['Distance', 'Length', 'Space', 'Range'],
    ),
    VocabularyQuestion(
      korean: '시간',
      correctAnswer: 'Time',
      options: ['Time', 'Duration', 'Period', 'Moment'],
    ),
    VocabularyQuestion(
      korean: '공간',
      correctAnswer: 'Space',
      options: ['Space', 'Area', 'Room', 'Place'],
    ),
    VocabularyQuestion(
      korean: '위치',
      correctAnswer: 'Location',
      options: ['Location', 'Position', 'Place', 'Site'],
    ),
    VocabularyQuestion(
      korean: '방향',
      correctAnswer: 'Direction',
      options: ['Direction', 'Way', 'Path', 'Route'],
    ),
  ];

  // Get random questions with smart selection to avoid recently used ones
  static List<VocabularyQuestion> getRandomQuestions(int count) {
    // 새로운 단어들을 우선적으로 선택
    final unusedQuestions = allQuestions
        .where((q) => !_recentlyUsedQuestions.contains(q.korean))
        .toList();
    
    final selectedQuestions = <VocabularyQuestion>[];
    
    // 1. 먼저 사용하지 않은 단어들부터 선택
    if (unusedQuestions.length >= count) {
      // 충분한 새로운 단어가 있는 경우
      unusedQuestions.shuffle();
      selectedQuestions.addAll(unusedQuestions.take(count));
    } else {
      // 새로운 단어가 부족한 경우
      // 모든 새로운 단어 추가
      unusedQuestions.shuffle();
      selectedQuestions.addAll(unusedQuestions);
      
      // 부족한 만큼 최근 사용된 단어 중에서 가장 오래된 것부터 선택
      final remainingCount = count - selectedQuestions.length;
      final recentlyUsedQuestions = allQuestions
          .where((q) => _recentlyUsedQuestions.contains(q.korean))
          .toList();
      
      recentlyUsedQuestions.shuffle();
      selectedQuestions.addAll(recentlyUsedQuestions.take(remainingCount));
    }
    
    // 2. 선택된 단어들을 최근 사용 목록에 추가
    for (final question in selectedQuestions) {
      _recentlyUsedQuestions.add(question.korean);
    }
    
    // 3. 최근 사용 목록이 너무 커지면 절반으로 줄이기 (메모리 관리)
    if (_recentlyUsedQuestions.length > allQuestions.length * 0.7) {
      final recentList = _recentlyUsedQuestions.toList()..shuffle();
      _recentlyUsedQuestions.clear();
      _recentlyUsedQuestions.addAll(recentList.take(allQuestions.length ~/ 3));
    }
    
    // 4. 최종 섞기
    selectedQuestions.shuffle();
    
    return selectedQuestions;
  }
}
