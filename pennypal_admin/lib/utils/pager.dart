class Pager {
  static const int pageSize = 8;

  static int pageCount(int total) {
    if (total == 0) return 1;
    return (total / pageSize).ceil();
  }

  static int safePage(int pageIndex, int total) {
    final int lastPage = pageCount(total) - 1;
    if (pageIndex > lastPage) return lastPage;
    return pageIndex;
  }

  static List<T> page<T>(List<T> items, int pageIndex) {
    final int start = pageIndex * pageSize;
    if (start >= items.length) return [];

    int end = start + pageSize;
    if (end > items.length) end = items.length;
    return items.sublist(start, end);
  }
}
