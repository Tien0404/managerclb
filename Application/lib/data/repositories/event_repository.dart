class Event {
  final int id;
  final String image;
  final String title;
  final String location;
  final String time;
  final String date;
  final bool proposal;
  final String status;

  Event({
    required this.id,
    required this.image,
    required this.title,
    required this.location,
    required this.time,
    required this.date,
    required this.proposal,
    required this.status,
  });
}

final List<Event> events = [
  Event(
    id: 1,
    image: 'assets/1.webp',
    title: 'Lorem eget venenatis vestibulum odio egestas bibendum urna...',
    location: 'TP. HCM',
    time: '10:00',
    date: '10/04/2024',
    proposal: false,
    status: 'Đang diễn ra',
  ),
  Event(
    id: 2,
    image: 'assets/2.webp',
    title: 'Elementum dignissim tristique pellentesque eleifend posuere.',
    location: 'TP. HCM',
    time: '10:00',
    date: '10/04/2024',
    proposal: true,
    status: 'Sắp diễn ra',
  ),
  Event(
    id: 3,
    image: 'assets/3.webp',
    title: 'Porta aliquet sed viverra fringilla.',
    location: 'TP. HCM',
    time: '10:00',
    date: '10/04/2024',
    proposal: false,
    status: 'Bản nháp',
  ),
  Event(
    id: 4,
    image: 'assets/4.webp',
    title: 'Non vitae tristique in sed aenean consectetur.',
    location: 'TP. HCM',
    time: '10:00',
    date: '10/04/2024',
    proposal: false,
    status: 'Đã kết thúc',
  ),
  Event(
    id: 5,
    image: 'assets/5.webp',
    title: 'Massa leo scelerisque bibendum eu commodo at vestibulum.',
    location: 'TP. HCM',
    time: '10:00',
    date: '10/04/2024',
    proposal: false,
    status: 'Đã kết thúc',
  ),
];