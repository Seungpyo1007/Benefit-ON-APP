import '../models/store.dart';

class AppConstants {
  static const String appTitle = '혜택ON';
  
  static final List<Store> stores = [
    // 영화관 정보
    Store(
      id: 'cgv-yongsan-ipark-01',
      name: 'CGV 용산아이파크몰',
      address: '서울 용산구 한강대로23길 55 아이파크몰 6층',
      category: Category.movie,
      discounts: [
        DiscountInfo(
          id: 'd-movie-youth-01',
          description: '청소년 할인 요금 적용',
          conditions: '만 13세 ~ 만 18세 청소년 대상. 신분증 또는 학생증 제시가 필요할 수 있습니다.',
        ),
      ],
      rating: 4.8,
      imageUrl: 'assets/images/logo-cgv.png',
      operatingHours: '상영 시간에 따라 상이',
      latitude: 37.5298,
      longitude: 126.9648,
    ),
    Store(
      id: 'lotte-cinema-worldtower-01',
      name: '롯데시네마 월드타워',
      address: '서울 송파구 올림픽로 300 롯데월드몰 5층',
      category: Category.movie,
      discounts: [
        DiscountInfo(
          id: 'd-movie-youth-02',
          description: '청소년 할인 요금 적용',
          conditions: '만 13세 ~ 만 18세 청소년 대상. 신분증 또는 학생증 제시가 필요할 수 있습니다.',
        ),
      ],
      rating: 4.7,
      imageUrl: 'assets/images/logo-lotte-cinema.png',
      operatingHours: '상영 시간에 따라 상이',
      latitude: 37.5125,
      longitude: 127.1025,
    ),
    Store(
      id: 'megabox-coex-01',
      name: '메가박스 코엑스',
      address: '서울 강남구 봉은사로 524 스타필드 코엑스몰 B1',
      category: Category.movie,
      discounts: [
        DiscountInfo(
          id: 'd-movie-youth-03',
          description: '청소년 할인 요금 적용',
          conditions: '만 13세 ~ 만 18세 청소년 대상. 신분증 또는 학생증 제시가 필요할 수 있습니다.',
        ),
      ],
      rating: 4.6,
      imageUrl: 'assets/images/logo-megabox.png',
      operatingHours: '상영 시간에 따라 상이',
      latitude: 37.5126,
      longitude: 127.0591,
    ),
    Store(
      id: 'ku-cinematheque-01',
      name: 'KU시네마테크',
      address: '서울 광진구 능동로 120 건국대학교 예술문화관',
      category: Category.movie,
      discounts: [
        DiscountInfo(
          id: 'd-arthouse-student-01',
          description: '학생(초/중/고/대학생) 할인',
          conditions: '학생증 제시 필수. 예술/독립 영화를 저렴하게 관람할 수 있습니다.',
        ),
      ],
      rating: 4.5,
      imageUrl: 'assets/images/ku-cinematheque-01.jpg',
      operatingHours: '상영 시간에 따라 상이',
      latitude: 37.5407,
      longitude: 127.0794,
    ),
    Store(
      id: 'cgv-gangnam-01',
      name: 'CGV 강남',
      address: '서울 강남구 강남대로 438',
      category: Category.movie,
      discounts: [
        DiscountInfo(
          id: 'd-movie-youth-04',
          description: '청소년 할인 요금 적용',
          conditions: '만 13세 ~ 만 18세 청소년 대상. 신분증 또는 학생증 제시가 필요할 수 있습니다.',
        ),
      ],
      rating: 4.7,
      imageUrl: 'assets/images/CGVgang.jpg',
      operatingHours: '상영 시간에 따라 상이',
      latitude: 37.4988,
      longitude: 127.028,
    ),

    // 음식점 정보
    Store(
      id: 'ashley-yongsan-01',
      name: '애슐리퀸즈 아이파크몰 용산점',
      address: '서울 용산구 한강대로23길 55 아이파크몰',
      category: Category.food,
      discounts: [
        DiscountInfo(
          id: 'd-ashley-01',
          description: '중/고/대학생 대상 슐리데이 프로모션',
          conditions: '학생증 제시 필수. 매월 마지막 주 화/수 등 특정일에 평일 런치 가격으로 이용 가능합니다.',
        ),
      ],
      rating: 4.5,
      imageUrl: 'assets/images/-yongashleysan-01.jpg',
      operatingHours: '11:00 - 21:00',
      latitude: 37.5298,
      longitude: 126.9648,
    ),
    Store(
      id: 'vips-itaewon-01',
      name: '빕스 이태원점',
      address: '서울 용산구 이태원로 177',
      category: Category.food,
      discounts: [
        DiscountInfo(
          id: 'd-vips-01',
          description: '청소년(만 14~19세) 할인 요금제 상시 적용',
          conditions: '주문 시 청소년증 또는 나이를 증명할 수 있는 신분증을 제시하세요.',
        ),
      ],
      rating: 4.4,
      imageUrl: 'assets/images/vips-itaewon-01.png',
      operatingHours: '지점별 상이',
      latitude: 37.5348,
      longitude: 126.9945,
    ),
    Store(
      id: 'pizzamall-01',
      name: '피자몰 (Pizza Mall)',
      address: '전국 피자몰 뷔페형 매장',
      category: Category.food,
      discounts: [
        DiscountInfo(
          id: 'd-pizzamall-01',
          description: '평일 저녁을 런치 가격으로 (중/고등학생)',
          conditions: '학생증/청소년증 제시 필수. 매월 마지막 주 화/수 등 특정일에 진행될 수 있습니다.',
        ),
      ],
      rating: 4.3,
      imageUrl: 'assets/images/PizzaMall.jpg',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'mrpizza-01',
      name: '미스터피자',
      address: '전국 미스터피자 매장',
      category: Category.food,
      discounts: [
        DiscountInfo(
          id: 'd-mrpizza-01',
          description: '시험 기간/방학 시즌 학생 응원 프로모션',
          conditions: '수능, 기말고사 등 시험 기간이나 방학 시즌에 학생 인증 시 할인 또는 사이드 메뉴 증정 이벤트를 진행합니다.',
        ),
      ],
      rating: 4.2,
      imageUrl: 'assets/images/MrPizza.png',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'dominospizza-01',
      name: '도미노피자',
      address: '전국 도미노피자 매장',
      category: Category.food,
      discounts: [
        DiscountInfo(
          id: 'd-dominospizza-01',
          description: '시험 기간/방학 시즌 학생 응원 프로모션',
          conditions: '수능, 기말고사 등 시험 기간이나 방학 시즌에 학생 인증 시 할인 또는 사이드 메뉴 증정 이벤트를 진행합니다.',
        ),
      ],
      rating: 4.5,
      imageUrl: 'assets/images/Dominos.png',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'pizzahut-01',
      name: '피자헛',
      address: '전국 피자헛 매장',
      category: Category.food,
      discounts: [
        DiscountInfo(
          id: 'd-pizzahut-01',
          description: '시험 기간/방학 시즌 학생 응원 프로모션',
          conditions: '수능, 기말고사 등 시험 기간이나 방학 시즌에 학생 인증 시 할인 또는 사이드 메뉴 증정 이벤트를 진행합니다.',
        ),
      ],
      rating: 4.3,
      imageUrl: 'assets/images/PizzaHut.jpg',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'starbucks-yongsan-ipark',
      name: '스타벅스 용산아이파크몰점',
      address: '서울 용산구 한강대로23길 55 아이파크몰',
      category: Category.food,
      discounts: [
        DiscountInfo(
          id: 'd-starbucks-01',
          description: '스튜던트 카드 발급 시 음료 혜택',
          conditions: '대학(원)생 인증 후 스튜던트 카드를 발급받으면 학기 중 특정 음료 사이즈 업그레이드 또는 할인 혜택을 받을 수 있습니다.',
        ),
      ],
      rating: 4.8,
      imageUrl: 'assets/images/Starbucks.png',
      operatingHours: '07:00 ~ 22:00',
    ),
    Store(
      id: 'starbucks-itaewon',
      name: '스타벅스 이태원역점',
      address: '서울 용산구 이태원로 187',
      category: Category.food,
      discounts: [
        DiscountInfo(
          id: 'd-starbucks-02',
          description: '스튜던트 카드 발급 시 음료 혜택',
          conditions: '대학(원)생 인증 후 스튜던트 카드를 발급받으면 학기 중 특정 음료 사이즈 업그레이드 또는 할인 혜택을 받을 수 있습니다.',
        ),
      ],
      rating: 4.6,
      imageUrl: 'assets/images/Starbucksitaewon.jpg',
      operatingHours: '07:00 ~ 22:00',
    ),
    Store(
      id: 'starbucks-sukdae',
      name: '스타벅스 숙대입구점',
      address: '서울 용산구 한강대로23길 55',
      category: Category.food,
      discounts: [
        DiscountInfo(
          id: 'd-starbucks-03',
          description: '스튜던트 카드 발급 시 음료 혜택',
          conditions: '대학(원)생 인증 후 스튜던트 카드를 발급받으면 학기 중 특정 음료 사이즈 업그레이드 또는 할인 혜택을 받을 수 있습니다.',
        ),
      ],
      rating: 4.7,
      imageUrl: 'assets/images/starbuckssukdae.jpg',
      operatingHours: '07:00 ~ 22:00',
    ),

    // 쇼핑 정보
    Store(
      id: 'teen-culture-01',
      name: '틴컬처',
      address: '전국 틴컬처 매장',
      category: Category.shopping,
      discounts: [
        DiscountInfo(
          id: 'd-teen-culture-01',
          description: '학생 할인 10%',
          conditions: '학생증 제시 시 10% 할인',
        ),
      ],
      rating: 4.3,
      imageUrl: 'assets/images/Teenculture.jpg',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'spao-01',
      name: 'SPAO',
      address: '전국 SPAO 매장',
      category: Category.shopping,
      discounts: [
        DiscountInfo(
          id: 'd-spao-01',
          description: '학생 할인 15%',
          conditions: '학생증 제시 시 15% 할인',
        ),
      ],
      rating: 4.2,
      imageUrl: 'assets/images/spao.jpg',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'whoau-01',
      name: 'WHO.A.U',
      address: '전국 WHO.A.U 매장',
      category: Category.shopping,
      discounts: [
        DiscountInfo(
          id: 'd-whoau-01',
          description: '학생 할인 10%',
          conditions: '학생증 제시 시 10% 할인',
        ),
      ],
      rating: 4.1,
      imageUrl: 'assets/images/WHOAU.jpg',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'nike-01',
      name: 'Nike',
      address: '전국 Nike 매장',
      category: Category.shopping,
      discounts: [
        DiscountInfo(
          id: 'd-nike-01',
          description: '학생 할인 20%',
          conditions: '학생증 제시 시 20% 할인',
        ),
      ],
      rating: 4.5,
      imageUrl: 'assets/images/Nike.jpg',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'adidas-01',
      name: 'Adidas',
      address: '전국 Adidas 매장',
      category: Category.shopping,
      discounts: [
        DiscountInfo(
          id: 'd-adidas-01',
          description: '학생 할인 15%',
          conditions: '학생증 제시 시 15% 할인',
        ),
      ],
      rating: 4.4,
      imageUrl: 'assets/images/Adidas.jpg',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'shoemarker-01',
      name: 'ShoeMarker',
      address: '전국 ShoeMarker 매장',
      category: Category.shopping,
      discounts: [
        DiscountInfo(
          id: 'd-shoemarker-01',
          description: '학생 할인 10%',
          conditions: '학생증 제시 시 10% 할인',
        ),
      ],
      rating: 4.0,
      imageUrl: 'assets/images/shoemarker.png',
      operatingHours: '지점별 상이',
    ),

    // 문화/공부 정보
    Store(
      id: 'national-museum-01',
      name: '국립중앙박물관',
      address: '서울 용산구 서빙고로 137',
      category: Category.culture,
      discounts: [
        DiscountInfo(
          id: 'd-museum-01',
          description: '무료 입장',
          conditions: '학생은 무료로 입장 가능합니다.',
        ),
      ],
      rating: 4.8,
      imageUrl: 'assets/images/nationalmuseum.jpg',
      operatingHours: '10:00 ~ 18:00',
    ),
    Store(
      id: 'national-act-01',
      name: '국립극단',
      address: '서울 중구 장충단로 59',
      category: Category.culture,
      discounts: [
        DiscountInfo(
          id: 'd-theater-01',
          description: '학생 할인 50%',
          conditions: '학생증 제시 시 50% 할인',
        ),
      ],
      rating: 4.6,
      imageUrl: 'assets/images/nationalact.png',
      operatingHours: '공연 시간에 따라 상이',
    ),
    Store(
      id: 'rium-museum-01',
      name: '리움미술관',
      address: '서울 용산구 이태원로55길 60-16',
      category: Category.culture,
      discounts: [
        DiscountInfo(
          id: 'd-rium-01',
          description: '학생 할인 50%',
          conditions: '학생증 제시 시 50% 할인',
        ),
      ],
      rating: 4.7,
      imageUrl: 'assets/images/riummuseum.png',
      operatingHours: '10:00 ~ 18:00',
    ),
    Store(
      id: 'kyobo-book-01',
      name: '교보문고',
      address: '전국 교보문고 매장',
      category: Category.study,
      discounts: [
        DiscountInfo(
          id: 'd-kyobo-01',
          description: '학생 할인 10%',
          conditions: '학생증 제시 시 10% 할인',
        ),
      ],
      rating: 4.4,
      imageUrl: 'assets/images/Kyobo.jpg',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'hottracks-01',
      name: '핫트랙스',
      address: '전국 핫트랙스 매장',
      category: Category.study,
      discounts: [
        DiscountInfo(
          id: 'd-hottracks-01',
          description: '학생 할인 5%',
          conditions: '학생증 제시 시 5% 할인',
        ),
      ],
      rating: 4.2,
      imageUrl: 'assets/images/Hottracks.jpg',
      operatingHours: '지점별 상이',
    ),
    Store(
      id: 'hottracks-study-01',
      name: '핫트랙스 스터디카페',
      address: '전국 핫트랙스 스터디카페',
      category: Category.study,
      discounts: [
        DiscountInfo(
          id: 'd-hottracks-study-01',
          description: '학생 할인 20%',
          conditions: '학생증 제시 시 20% 할인',
        ),
      ],
      rating: 4.3,
      imageUrl: 'assets/images/HottracksStudy.jpg',
      operatingHours: '24시간',
    ),

    // 기타 정보
    Store(
      id: 'coex-aqua-01',
      name: '코엑스 아쿠아리움',
      address: '서울 강남구 봉은사로 524 스타필드 코엑스몰 B1',
      category: Category.other,
      discounts: [
        DiscountInfo(
          id: 'd-aqua-01',
          description: '학생 할인 30%',
          conditions: '학생증 제시 시 30% 할인',
        ),
      ],
      rating: 4.5,
      imageUrl: 'assets/images/coexaqua.jpg',
      operatingHours: '10:00 ~ 20:00',
    ),
    Store(
      id: 'n-seoul-tower-01',
      name: 'N서울타워',
      address: '서울 용산구 남산공원길 105',
      category: Category.other,
      discounts: [
        DiscountInfo(
          id: 'd-tower-01',
          description: '학생 할인 25%',
          conditions: '학생증 제시 시 25% 할인',
        ),
      ],
      rating: 4.6,
      imageUrl: 'assets/images/Nseoul.jpg',
      operatingHours: '10:00 ~ 23:00',
    ),
    Store(
      id: 'basketball-court-01',
      name: '농구장',
      address: '전국 공공 농구장',
      category: Category.free,
      discounts: [
        DiscountInfo(
          id: 'd-basketball-01',
          description: '무료 이용',
          conditions: '공공 농구장은 무료로 이용 가능합니다.',
        ),
      ],
      rating: 4.0,
      imageUrl: 'assets/images/basketball.jpg',
      operatingHours: '24시간',
    ),
  ];
} 