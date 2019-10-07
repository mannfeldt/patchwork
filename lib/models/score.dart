class Score implements Comparable {
  int plus;
  int minus;
  int extra;
  int total;

  Score(final int plus, final int minus, final int extra) {
    this.plus = plus;
    this.minus = minus;
    this.extra = extra;
    this.total = plus - minus + extra;
  }

  @override
  int compareTo(other) {
    return this.total - other.total;
  }
}
