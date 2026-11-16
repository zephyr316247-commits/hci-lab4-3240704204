using System;
using System.Diagnostics;
using System.Windows.Forms;
using Microsoft.VisualBasic;

namespace Lab4_3240704204
{
    /// <summary>
    /// 定时访问窗体：时/分/秒数值控件（支持秒满 60 进分、分满 60 进时、时满 24 归零），
    /// 一个计时器刷新当前时间，一个计时器负责到点触发；启动后锁住输入，目标时刻在过去时拒绝启动。
    /// </summary>
    public partial class TimerForm : Form
    {
        private bool adjusting;
        private bool running;
        private DateTime target;

        public TimerForm()
        {
            InitializeComponent();
            txtUrl.Text = PersonalParameters.P7Url;
            SetDefaultTarget();
        }

        private void SetDefaultTarget()
        {
            DateTime t = DateTime.Now.AddSeconds(30);
            adjusting = true;
            numHour.Value = t.Hour;
            numMinute.Value = t.Minute;
            numSecond.Value = t.Second;
            adjusting = false;
            UpdateTargetLabel();
            UpdateNow();
        }

        private void Numeric_ValueChanged(object sender, EventArgs e)
        {
            if (adjusting) return;

            int h = (int)numHour.Value;
            int m = (int)numMinute.Value;
            int s = (int)numSecond.Value;
            bool changed = false;

            if (s >= 60) { s = 0; m++; changed = true; }
            if (m >= 60) { m = 0; h++; changed = true; }
            if (h >= 24) { h = 0; changed = true; }

            if (changed)
            {
                adjusting = true;
                numHour.Value = h;
                numMinute.Value = m;
                numSecond.Value = s;
                adjusting = false;
            }
            UpdateTargetLabel();
        }

        private void UpdateTargetLabel()
        {
            lblTarget.Text = string.Format("目标时刻：{0:00}:{1:00}:{2:00}",
                (int)numHour.Value, (int)numMinute.Value, (int)numSecond.Value);
        }

        private void displayTimer_Tick(object sender, EventArgs e)
        {
            UpdateNow();
        }

        private void UpdateNow()
        {
            DateTime now = DateTime.Now;
            lblNow.Text = "当前时间：" + now.ToString("HH:mm:ss");
            if (!running)
            {
                lblRemain.Text = "剩余：-- 秒";
                return;
            }

            long remain = DateAndTime.DateDiff(DateInterval.Second, now, target,
                FirstDayOfWeek.Sunday, FirstWeekOfYear.Jan1);
            if (remain < 0) remain = 0;
            lblRemain.Text = "剩余：" + remain + " 秒";
        }

        private void btnStart_Click(object sender, EventArgs e)
        {
            if (running) return;

            string url = txtUrl.Text.Trim();
            Uri uri;
            if (!Uri.TryCreate(url, UriKind.Absolute, out uri))
            {
                MessageBox.Show(this, "网址格式不正确，请输入完整网址（例如 https://jwc.ahpu.edu.cn）。",
                    "网址无效", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            target = DateTime.Today
                .AddHours((int)numHour.Value)
                .AddMinutes((int)numMinute.Value)
                .AddSeconds((int)numSecond.Value);

            if (target <= DateTime.Now)
            {
                MessageBox.Show(this,
                    "目标时刻 " + target.ToString("HH:mm:ss") + " 早于或等于当前时间 " +
                    DateTime.Now.ToString("HH:mm:ss") + "，任务不会触发。\n\n请把时/分/秒改到当前时间之后，再点“启动”。",
                    "时刻不合法", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                return;
            }

            running = true;
            SetInputsEnabled(false);
            displayTimer.Start();
            triggerTimer.Start();
            UpdateNow();
        }

        private void SetInputsEnabled(bool enabled)
        {
            txtUrl.Enabled = enabled;
            numHour.Enabled = enabled;
            numMinute.Enabled = enabled;
            numSecond.Enabled = enabled;
            btnStart.Enabled = enabled;
            btnCancel.Enabled = !enabled;
        }

        private void triggerTimer_Tick(object sender, EventArgs e)
        {
            if (!running) return;
            if (DateTime.Now >= target) Trigger();
        }

        private void Trigger()
        {
            triggerTimer.Stop();
            displayTimer.Stop();
            running = false;
            SetInputsEnabled(true);
            lblRemain.Text = "剩余：0 秒";

            string url = txtUrl.Text.Trim();
            try
            {
                Process.Start(new ProcessStartInfo(url) { UseShellExecute = true });
                MessageBox.Show(this,
                    "已到设定时刻 " + target.ToString("HH:mm:ss") + "，已自动打开浏览器。",
                    "定时访问", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (Exception ex)
            {
                MessageBox.Show(this,
                    "到点后打开浏览器失败：" + ex.Message + "\n\n请检查网址或系统默认浏览器设置。",
                    "定时访问", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void btnCancel_Click(object sender, EventArgs e)
        {
            if (!running) return;
            triggerTimer.Stop();
            displayTimer.Stop();
            running = false;
            SetInputsEnabled(true);
            lblRemain.Text = "剩余：-- 秒";
        }

        private void btnExit_Click(object sender, EventArgs e)
        {
            Close();
        }

        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            triggerTimer.Stop();
            displayTimer.Stop();
            base.OnFormClosing(e);
        }
    }
}
