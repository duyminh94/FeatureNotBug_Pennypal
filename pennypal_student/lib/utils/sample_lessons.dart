import '../models/learning_content.dart';
import 'constants.dart';

class SampleLessons {
  static List<LearningContent> all() {
    final DateTime now = DateTime.now();
    int daysAgo(int days) => now.subtract(Duration(days: days)).millisecondsSinceEpoch;

    return [
      LearningContent(
        id: 'lesson_50_30_20',
        topic: LearningTopics.budgeting,
        createdAt: daysAgo(1),
        titleEn: 'The 50/30/20 rule for students: how to split your money',
        titleVi: 'Quy tắc 50/30/20 cho sinh viên: chia tiền sao cho đủ?',
        bodyEn: '''Every time you receive money — allowance, scholarship or part-time pay — split it into three parts before you spend anything. This stops the "broke by the middle of the month" feeling.

50% for needs: food, transport, rent and textbooks. 30% for wants: coffee, movies and shopping. 20% for savings: put it into a goal or an emergency fund.

Example: you receive 5,000,000 VND a month. Needs get 2,500,000, wants get 1,500,000 and savings get 1,000,000.

The numbers are not fixed. If your rent is high, 60/20/20 is fine. What matters is that savings are paid first, not whatever is left over.

Try it: create a total budget for this month equal to 80% of the money you receive.''',
        bodyVi: '''Mỗi khi nhận tiền — trợ cấp, học bổng hay lương làm thêm — hãy chia ngay thành 3 phần trước khi tiêu. Cách này giúp bạn không bị "hết tiền giữa tháng".

50% cho nhu cầu thiết yếu: tiền ăn, đi lại, tiền nhà, giáo trình. 30% cho mong muốn: cà phê, xem phim, mua sắm. 20% cho tiết kiệm: góp vào mục tiêu hoặc quỹ dự phòng.

Ví dụ: nhận 5.000.000 đ mỗi tháng. Thiết yếu 2.500.000, mong muốn 1.500.000, tiết kiệm 1.000.000.

Tỷ lệ không cố định: nếu tiền nhà cao, bạn có thể dùng 60/20/20. Quan trọng là phần tiết kiệm được "trả trước", không phải phần còn thừa.

Thử ngay: tạo ngân sách tổng tháng này bằng 80% số tiền bạn nhận.''',
      ),
      LearningContent(
        id: 'lesson_save_10',
        topic: LearningTopics.saving,
        createdAt: daysAgo(2),
        titleEn: 'Save 10% every time you get paid — a small habit with big results',
        titleVi: 'Để dành 10% mỗi khi nhận tiền — thói quen nhỏ, kết quả lớn',
        bodyEn: '''You do not need a lot of money to start saving. You need a habit.

Each time money comes in, move 10% into savings on the same day. If you get 3,000,000 VND, save 300,000 before buying anything else.

Why the same day? Money that stays in your wallet gets spent. Moving it right away makes saving automatic.

After one year, 300,000 VND a month becomes 3,600,000 VND — enough for a new phone or a short trip.

Give your savings a name. "New laptop" is easier to protect than "savings". Create a goal in PennyPal and add a contribution each time you get paid.''',
        bodyVi: '''Không cần nhiều tiền mới bắt đầu tiết kiệm được. Bạn chỉ cần một thói quen.

Mỗi lần có tiền vào, chuyển ngay 10% sang tiết kiệm trong ngày. Nhận 3.000.000 đ thì để dành 300.000 đ trước khi mua bất cứ thứ gì.

Vì sao phải làm ngay trong ngày? Tiền nằm trong ví sẽ bị tiêu. Chuyển đi ngay thì việc tiết kiệm trở thành tự động.

Sau một năm, 300.000 đ mỗi tháng thành 3.600.000 đ — đủ cho một chiếc điện thoại mới hoặc một chuyến đi ngắn.

Hãy đặt tên cho khoản tiết kiệm. "Laptop mới" dễ giữ hơn "tiền tiết kiệm". Tạo một mục tiêu trong PennyPal và góp tiền mỗi lần nhận lương.''',
      ),
      LearningContent(
        id: 'lesson_needs_wants',
        topic: LearningTopics.needsVsWants,
        level: LearningLevels.intermediate,
        createdAt: daysAgo(3),
        titleEn: 'Bubble tea or a textbook? Telling needs from wants',
        titleVi: 'Trà sữa hay giáo trình? Phân biệt "cần" và "muốn"',
        bodyEn: '''A need is something you must pay for to live and study: meals, rent, transport to class, required textbooks.

A want makes life nicer but you can live without it: bubble tea, new clothes when your old ones still fit, a streaming subscription.

Some things are both. You need food, but a 150,000 VND restaurant dinner is partly a want. The need is the basic meal; the extra is the want.

Before buying, ask two questions: "What happens if I do not buy this?" and "Is there a cheaper way to meet the same need?"

Wants are not bad. Just plan them inside your budget instead of letting them eat into money for needs.''',
        bodyVi: '''"Cần" là thứ bạn phải trả để sống và học: bữa ăn, tiền nhà, đi lại đến lớp, giáo trình bắt buộc.

"Muốn" là thứ làm cuộc sống vui hơn nhưng thiếu cũng không sao: trà sữa, quần áo mới khi đồ cũ vẫn mặc được, gói xem phim.

Có thứ vừa cần vừa muốn. Bạn cần ăn, nhưng bữa tối 150.000 đ ở nhà hàng thì một phần là "muốn". Phần cần là bữa ăn cơ bản; phần dư là mong muốn.

Trước khi mua, hãy tự hỏi hai câu: "Nếu không mua thì sao?" và "Có cách nào rẻ hơn để đáp ứng cùng nhu cầu không?"

"Muốn" không có gì xấu. Chỉ cần lên kế hoạch cho nó trong ngân sách thay vì để nó lấn sang tiền thiết yếu.''',
      ),
      LearningContent(
        id: 'lesson_income_sources',
        topic: LearningTopics.income,
        createdAt: daysAgo(4),
        titleEn: 'Where does your money come from? Tracking every income source',
        titleVi: 'Tiền của bạn đến từ đâu? Ghi lại mọi nguồn thu',
        bodyEn: '''Most students have more than one income source: allowance from parents, scholarships, part-time jobs or internships.

Record each one separately. When you know that 60% of your money comes from a part-time job, you know what happens if you stop working during exam season.

Some income is regular, like a monthly allowance. Some is irregular, like a one-time scholarship. Plan your monthly budget with regular income only, and treat irregular income as a bonus for savings.

At the end of each month, compare income with spending. If spending is higher, look at your wants first before asking for more money.''',
        bodyVi: '''Phần lớn sinh viên có hơn một nguồn thu: trợ cấp từ bố mẹ, học bổng, việc làm thêm hoặc thực tập.

Hãy ghi riêng từng nguồn. Khi biết 60% tiền đến từ việc làm thêm, bạn sẽ biết chuyện gì xảy ra nếu nghỉ làm vào mùa thi.

Có khoản thu đều đặn như trợ cấp hằng tháng. Có khoản không đều như học bổng một lần. Hãy lập ngân sách tháng chỉ dựa trên khoản thu đều, còn khoản không đều thì coi là tiền thưởng để tiết kiệm.

Cuối mỗi tháng, so thu với chi. Nếu chi nhiều hơn, hãy xem lại các khoản "muốn" trước khi xin thêm tiền.''',
      ),
      LearningContent(
        id: 'lesson_smart_spending',
        topic: LearningTopics.smartSpending,
        createdAt: daysAgo(5),
        titleEn: 'The 24-hour rule: stop impulse buying',
        titleVi: 'Quy tắc 24 giờ: dừng mua sắm bốc đồng',
        bodyEn: '''Saw something you want online? Wait 24 hours before buying it.

Most impulse purchases feel important for a few minutes and much less the next day. If you still want it after 24 hours and it fits your budget, buy it without guilt.

Other simple tricks: remove saved cards from shopping apps, turn off sale notifications, and check the price per use — a 300,000 VND jacket you wear 100 times is cheaper than a 100,000 VND shirt you wear twice.

Snap a photo of receipts in PennyPal. Seeing where your money went is the first step to spending it better.''',
        bodyVi: '''Thấy món đồ muốn mua trên mạng? Hãy đợi 24 giờ rồi mới quyết định.

Phần lớn món mua bốc đồng chỉ có vẻ quan trọng trong vài phút và bớt hấp dẫn hẳn vào hôm sau. Nếu sau 24 giờ vẫn muốn và vẫn nằm trong ngân sách, cứ mua mà không cần áy náy.

Vài mẹo đơn giản khác: xoá thẻ đã lưu khỏi app mua sắm, tắt thông báo khuyến mãi, và tính giá theo số lần dùng — áo khoác 300.000 đ mặc 100 lần rẻ hơn áo phông 100.000 đ chỉ mặc 2 lần.

Chụp hoá đơn bằng PennyPal. Thấy rõ tiền đã đi đâu là bước đầu tiên để tiêu tiền khôn ngoan hơn.''',
      ),
      LearningContent(
        id: 'lesson_emergency_fund',
        topic: LearningTopics.saving,
        level: LearningLevels.intermediate,
        createdAt: daysAgo(6),
        titleEn: 'Build a small emergency fund before anything else',
        titleVi: 'Xây quỹ dự phòng nhỏ trước mọi mục tiêu khác',
        bodyEn: '''An emergency fund is money you only touch when something unexpected happens: a broken phone, a medical bill or a late allowance.

For a student, a good first target is one month of basic needs. If your needs cost 2,500,000 VND a month, aim for 2,500,000 VND.

Keep it separate from your spending money so you do not use it by accident. Create a goal called "Emergency fund" and contribute a little each month.

When you use it, refill it before saving for other goals. It is your safety net.''',
        bodyVi: '''Quỹ dự phòng là khoản tiền chỉ dùng khi có chuyện bất ngờ: hỏng điện thoại, tiền khám bệnh hay trợ cấp về trễ.

Với sinh viên, mục tiêu đầu tiên hợp lý là đủ một tháng chi tiêu thiết yếu. Nếu thiết yếu tốn 2.500.000 đ mỗi tháng, hãy đặt mục tiêu 2.500.000 đ.

Để riêng khỏi tiền tiêu hằng ngày để không lỡ tay dùng mất. Tạo một mục tiêu tên "Quỹ dự phòng" và góp một ít mỗi tháng.

Khi đã dùng, hãy bù lại trước khi tiết kiệm cho mục tiêu khác. Đây là tấm lưới an toàn của bạn.''',
      ),
      LearningContent(
        id: 'lesson_draft',
        topic: LearningTopics.income,
        isActive: false,
        createdAt: daysAgo(0),
        titleEn: 'Draft: side hustles for students',
        titleVi: 'Bản nháp: việc làm thêm cho sinh viên',
        bodyEn: 'This lesson is not published yet.',
        bodyVi: 'Bài này chưa được đăng.',
      ),
    ];
  }
}
