using System;
using System.Collections.Generic;
using System.Net;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Lab4_3240704204
{
    /// <summary>
    /// 简易浏览器主窗体：WebBrowser + 工具栏 + 地址栏（P8 访问历史下拉）+ 缩放（P8 页面缩放）
    /// + 状态栏（P8 标题显示）。默认主页为 P7 指定的教务处。
    /// </summary>
    public partial class BrowserForm : Form
    {
        private readonly List<string> history = new List<string>();
        private string pendingUrl = "";
        private bool documentCompleted;

        public BrowserForm() : this(null)
        {
        }

        public BrowserForm(string initialUrl)
        {
            InitializeComponent();
            KeyPreview = true;
            mnuTimer.ShortcutKeys = Keys.Control | Keys.T;
            cmbZoom.SelectedIndex = 2; // 100%
            NavigateTo(string.IsNullOrWhiteSpace(initialUrl) ? PersonalParameters.P7Url : initialUrl);
        }

        protected override bool ProcessCmdKey(ref Message msg, Keys keyData)
        {
            if (keyData == (Keys.Control | Keys.L))
            {
                cmbAddress.Focus();
                cmbAddress.SelectAll();
                return true;
            }
            if (keyData == (Keys.Control | Keys.T))
            {
                Timer_Click(this, EventArgs.Empty);
                return true;
            }
            return base.ProcessCmdKey(ref msg, keyData);
        }

        // ---------------- 导航 ----------------

        private void NavigateTo(string url)
        {
            if (string.IsNullOrWhiteSpace(url)) return;
            url = url.Trim();

            Uri uri;
            if (!Uri.TryCreate(url, UriKind.Absolute, out uri))
            {
                MessageBox.Show(this, "网址格式不正确：\n" + url + "\n\n请输入完整网址（例如 https://jwc.ahpu.edu.cn）。",
                    "地址无效", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            pendingUrl = uri.ToString();
            lblStatus.Text = "正在打开 " + uri.Host;
            try
            {
                // 导航前先做 DNS 预检：断网或域名不存在时能立即给出可重试的提示，
                // 而不是等 WebBrowser 自己转到“无法显示此网页”的错误页。
                if (uri.Scheme == Uri.UriSchemeHttp || uri.Scheme == Uri.UriSchemeHttps)
                {
                    // 带 2 秒超时的 DNS 预检：断网/域名不存在时立即给出可重试提示，
                    // 而不是让界面长时间无响应或直接显示 IE 的错误页。
                    Task<IPHostEntry> lookup = Task.Run(() => Dns.GetHostEntry(uri.Host));
                    if (!lookup.Wait(2000))
                    {
                        throw new TimeoutException("DNS 解析超时（2 秒）");
                    }
                    if (lookup.IsFaulted && lookup.Exception != null)
                    {
                        throw lookup.Exception.GetBaseException();
                    }
                }
            }
            catch (Exception ex)
            {
                lblStatus.Text = "打开失败";
                ShowNavigationError(uri.ToString(), ex.Message);
                return;
            }

            try
            {
                webBrowser.Navigate(uri);
            }
            catch (Exception ex)
            {
                ShowNavigationError(uri.ToString(), ex.Message);
            }
        }

        private void ShowNavigationError(string url, string reason)
        {
            DialogResult result = MessageBox.Show(this,
                "无法打开页面：\n" + url + "\n\n可能原因：" + reason +
                "\n\n请检查网络连接后点击“重试”。",
                "加载失败", MessageBoxButtons.RetryCancel, MessageBoxIcon.Warning);
            if (result == DialogResult.Retry)
            {
                NavigateTo(url);
            }
        }

        private void webBrowser_Navigating(object sender, WebBrowserNavigatingEventArgs e)
        {
            documentCompleted = false;
            lblStatus.Text = "正在打开 " + (e.Url == null ? "" : e.Url.Host);
            progressBar.Visible = true;
            progressBar.Value = 0;
        }

        private void webBrowser_DocumentCompleted(object sender, WebBrowserDocumentCompletedEventArgs e)
        {
            documentCompleted = true;
            string url = e.Url == null ? "" : e.Url.ToString();
            string title = webBrowser.DocumentTitle;

            lblTitle.Text = "标题：" + (string.IsNullOrEmpty(title) ? url : title);
            lblUrl.Text = url;
            cmbAddress.Text = url;
            progressBar.Value = 100;
            progressBar.Visible = false;
            lblStatus.Text = "加载完成";

            if (!string.IsNullOrEmpty(url) && !url.StartsWith("about:", StringComparison.OrdinalIgnoreCase))
            {
                AddHistory(url);
            }

            Text = "实验四 简易浏览器 — " + PersonalParameters.StudentId;
            UpdateNavButtons();
        }

        private void webBrowser_ProgressChanged(object sender, WebBrowserProgressChangedEventArgs e)
        {
            if (documentCompleted) return;
            if (e.CurrentProgress <= 0)
            {
                progressBar.Visible = false;
                return;
            }
            int value = (int)Math.Min(100, Math.Max(0, e.CurrentProgress));
            progressBar.Value = value;
            progressBar.Visible = value < 100;
            lblStatus.Text = "加载中 " + value + "%";
        }

        private void AddHistory(string url)
        {
            history.Remove(url);
            history.Insert(0, url);
            if (history.Count > 20) history.RemoveAt(history.Count - 1);
            cmbAddress.Items.Clear();
            cmbAddress.Items.AddRange(history.ToArray());
        }

        private void UpdateNavButtons()
        {
            tsBack.Enabled = webBrowser.CanGoBack;
            mnuBack.Enabled = webBrowser.CanGoBack;
            tsForward.Enabled = webBrowser.CanGoForward;
            mnuForward.Enabled = webBrowser.CanGoForward;
        }

        private void Home_Click(object sender, EventArgs e)
        {
            NavigateTo(PersonalParameters.P7Url);
        }

        private void Back_Click(object sender, EventArgs e)
        {
            if (webBrowser.CanGoBack) webBrowser.GoBack();
        }

        private void Forward_Click(object sender, EventArgs e)
        {
            if (webBrowser.CanGoForward) webBrowser.GoForward();
        }

        private void Stop_Click(object sender, EventArgs e)
        {
            webBrowser.Stop();
            lblStatus.Text = "已停止";
        }

        private void Refresh_Click(object sender, EventArgs e)
        {
            webBrowser.Refresh();
            lblStatus.Text = "正在刷新";
        }

        private void cmbAddress_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
            {
                e.SuppressKeyPress = true;
                NavigateTo(cmbAddress.Text);
            }
        }

        private void btnGo_Click(object sender, EventArgs e)
        {
            NavigateTo(cmbAddress.Text);
        }

        // ---------------- P8② 页面缩放 ----------------

        private void cmbZoom_SelectedIndexChanged(object sender, EventArgs e)
        {
            ApplyZoom();
        }

        private void ApplyZoom()
        {
            if (webBrowser.Document == null || webBrowser.Document.Body == null) return;
            string text = Convert.ToString(cmbZoom.SelectedItem);
            string pct = text.Replace("%", "").Trim();
            try
            {
                webBrowser.Document.Body.Style = "zoom:" + pct + "%";
                lblStatus.Text = "页面缩放 " + pct + "%";
            }
            catch (Exception)
            {
                lblStatus.Text = "当前页面不支持缩放";
            }
        }

        // ---------------- 页面操作 ----------------

        private void SaveAs_Click(object sender, EventArgs e)
        {
            RunPageAction("另存为", delegate { webBrowser.ShowSaveAsDialog(); });
        }

        private void PageSetup_Click(object sender, EventArgs e)
        {
            RunPageAction("页面设置", delegate { webBrowser.ShowPageSetupDialog(); });
        }

        private void PrintPreview_Click(object sender, EventArgs e)
        {
            RunPageAction("打印预览", delegate { webBrowser.ShowPrintPreviewDialog(); });
        }

        private void Properties_Click(object sender, EventArgs e)
        {
            RunPageAction("页面属性", delegate { webBrowser.ShowPropertiesDialog(); });
        }

        private void RunPageAction(string name, Action action)
        {
            if (webBrowser.Document == null)
            {
                MessageBox.Show(this, "当前没有打开的页面，请先加载一个网址。", name,
                    MessageBoxButtons.OK, MessageBoxIcon.Information);
                return;
            }
            try
            {
                action();
            }
            catch (Exception ex)
            {
                MessageBox.Show(this, name + "失败：" + ex.Message, name,
                    MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        // ---------------- 定时访问 / 关于 / 退出 ----------------

        private void Timer_Click(object sender, EventArgs e)
        {
            using (TimerForm form = new TimerForm())
            {
                form.ShowDialog(this);
            }
        }

        private void About_Click(object sender, EventArgs e)
        {
            MessageBox.Show(this,
                "实验四 网络访问与服务\n学号：" + PersonalParameters.StudentId +
                "\nP7 默认主页：" + PersonalParameters.P7Name + "（" + PersonalParameters.P7Url + "）" +
                "\nP8 增强：" + PersonalParameters.P8NameA + " + " + PersonalParameters.P8NameB +
                "\n\nWebBrowser 使用本机 IE 内核，部分新版网页可能显示异常。",
                "关于", MessageBoxButtons.OK, MessageBoxIcon.Information);
        }

        private void Exit_Click(object sender, EventArgs e)
        {
            Close();
        }

        protected override void OnFormClosed(FormClosedEventArgs e)
        {
            webBrowser.Stop();
            base.OnFormClosed(e);
        }
    }
}
