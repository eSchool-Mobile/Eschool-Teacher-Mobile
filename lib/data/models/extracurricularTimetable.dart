class ExtracurricularTimetable {
  final int? id;
  final int? no;
  final String? extracurricularName;
  final String? monday;
  final String? tuesday;
  final String? wednesday;
  final String? thursday;
  final String? friday;
  final String? saturday;
  final String? sunday;

  ExtracurricularTimetable({
    this.id,
    this.no,
    this.extracurricularName,
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory ExtracurricularTimetable.fromJson(Map<String, dynamic> json) {
    return ExtracurricularTimetable(
      id: json['id'] as int?,
      no: json['no'] as int?,
      extracurricularName: json['estrakulikuler_name'] as String?,
      monday: json['Monday'] as String?,
      tuesday: json['Tuesday'] as String?,
      wednesday: json['Wednesday'] as String?,
      thursday: json['Thursday'] as String?,
      friday: json['Friday'] as String?,
      saturday: json['Saturday'] as String?,
      sunday: json['Sunday'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'no': no,
        'estrakulikuler_name': extracurricularName,
        'Monday': monday,
        'Tuesday': tuesday,
        'Wednesday': wednesday,
        'Thursday': thursday,
        'Friday': friday,
        'Saturday': saturday,
        'Sunday': sunday,
      };

  // Helper method to get schedule for a specific day
  String? getScheduleForDay(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return monday;
      case 'tuesday':
        return tuesday;
      case 'wednesday':
        return wednesday;
      case 'thursday':
        return thursday;
      case 'friday':
        return friday;
      case 'saturday':
        return saturday;
      case 'sunday':
        return sunday;
      default:
        return null;
    }
  }

  // Check if has schedule for a specific day
  bool hasScheduleForDay(String day) {
    final schedule = getScheduleForDay(day);
    return schedule != null && schedule != '-' && schedule.isNotEmpty;
  }
}
