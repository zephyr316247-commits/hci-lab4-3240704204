using System;
using System.Windows.Forms;

namespace Lab4_3240704204
{
    internal static class Program
    {
        [STAThread]
        private static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            string initialUrl = args != null && args.Length > 0 ? args[0] : null;
            Application.Run(new BrowserForm(initialUrl));
        }
    }
}
