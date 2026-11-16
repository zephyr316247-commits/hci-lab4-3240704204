using System;

namespace Lab4_3240704204
{
    /// <summary>
    /// 个人参数集中记录（指导书 7.1 / 7.3 第 4 条）。
    /// 学号 3240704204，S = 4204。
    /// P7 = S mod 6 = 4 → 教务处；P8 两项 = 增强池[(S div 2) mod 3] 与下一位
    /// = 页面缩放与标题显示 + 访问历史下拉。
    /// </summary>
    public static class PersonalParameters
    {
        public const string StudentId = "3240704204";
        public const string StudentName = "王志远";
        public static readonly int S = 4204;

        public const string ExperimentNo = "实验4";
        public const string ProjectName = "实验4_3240704204";

        // ---- P7 浏览器默认主页：站点池[S mod 6] ----
        public static readonly string[] SitePool =
        {
            "学校主页", "中国大学 MOOC", "维基百科", "学校图书馆", "教务处", "一个本地 HTML 文件"
        };
        public static readonly string[] SiteUrls =
        {
            "https://www.ahpu.edu.cn", "https://www.icourse163.org", "https://zh.wikipedia.org",
            "https://lib.ahpu.edu.cn", "https://jwc.ahpu.edu.cn", ""
        };

        public static int P7Index { get { return S % 6; } }
        public static string P7Name { get { return SitePool[P7Index]; } }
        public static string P7Url { get { return SiteUrls[P7Index]; } }

        // ---- P8 浏览器必做增强两项：增强池[(S div 2) mod 3] 与下一位 ----
        public static readonly string[] EnhancementPool =
        {
            "访问历史下拉", "加载进度与状态提示", "页面缩放与标题显示"
        };
        public static int P8IndexA { get { return (S / 2) % 3; } }
        public static int P8IndexB { get { return (P8IndexA + 1) % 3; } }
        public static string P8NameA { get { return EnhancementPool[P8IndexA]; } }
        public static string P8NameB { get { return EnhancementPool[P8IndexB]; } }
    }
}
