namespace Lab4_3240704204
{
    partial class TimerForm
    {
        private System.ComponentModel.IContainer components = null;

        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null)) components.Dispose();
            base.Dispose(disposing);
        }

        #region Windows 窗体设计器生成的代码

        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.lblUrl = new System.Windows.Forms.Label();
            this.txtUrl = new System.Windows.Forms.TextBox();
            this.gbTarget = new System.Windows.Forms.GroupBox();
            this.lblHour = new System.Windows.Forms.Label();
            this.numHour = new System.Windows.Forms.NumericUpDown();
            this.lblMinute = new System.Windows.Forms.Label();
            this.numMinute = new System.Windows.Forms.NumericUpDown();
            this.lblSecond = new System.Windows.Forms.Label();
            this.numSecond = new System.Windows.Forms.NumericUpDown();
            this.lblTarget = new System.Windows.Forms.Label();
            this.lblNow = new System.Windows.Forms.Label();
            this.lblRemain = new System.Windows.Forms.Label();
            this.btnStart = new System.Windows.Forms.Button();
            this.btnCancel = new System.Windows.Forms.Button();
            this.btnExit = new System.Windows.Forms.Button();
            this.lblHint = new System.Windows.Forms.Label();
            this.displayTimer = new System.Windows.Forms.Timer(this.components);
            this.triggerTimer = new System.Windows.Forms.Timer(this.components);
            this.gbTarget.SuspendLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numHour)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numMinute)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.numSecond)).BeginInit();
            this.SuspendLayout();
            // 
            // lblUrl
            // 
            this.lblUrl.AutoSize = true;
            this.lblUrl.Location = new System.Drawing.Point(16, 22);
            this.lblUrl.Name = "lblUrl";
            this.lblUrl.Size = new System.Drawing.Size(65, 12);
            this.lblUrl.TabIndex = 0;
            this.lblUrl.Text = "目标网址：";
            // 
            // txtUrl
            // 
            this.txtUrl.Location = new System.Drawing.Point(92, 18);
            this.txtUrl.Name = "txtUrl";
            this.txtUrl.Size = new System.Drawing.Size(480, 21);
            this.txtUrl.TabIndex = 1;
            // 
            // gbTarget
            // 
            this.gbTarget.Controls.Add(this.lblHour);
            this.gbTarget.Controls.Add(this.numHour);
            this.gbTarget.Controls.Add(this.lblMinute);
            this.gbTarget.Controls.Add(this.numMinute);
            this.gbTarget.Controls.Add(this.lblSecond);
            this.gbTarget.Controls.Add(this.numSecond);
            this.gbTarget.Controls.Add(this.lblTarget);
            this.gbTarget.Location = new System.Drawing.Point(16, 56);
            this.gbTarget.Name = "gbTarget";
            this.gbTarget.Size = new System.Drawing.Size(556, 96);
            this.gbTarget.TabIndex = 2;
            this.gbTarget.TabStop = false;
            this.gbTarget.Text = "目标时刻（时 / 分 / 秒，允许进位）";
            // 
            // lblHour
            // 
            this.lblHour.AutoSize = true;
            this.lblHour.Location = new System.Drawing.Point(20, 34);
            this.lblHour.Name = "lblHour";
            this.lblHour.Size = new System.Drawing.Size(17, 12);
            this.lblHour.TabIndex = 0;
            this.lblHour.Text = "时";
            // 
            // numHour
            // 
            this.numHour.Location = new System.Drawing.Point(44, 30);
            this.numHour.Maximum = new decimal(new int[] {24, 0, 0, 0});
            this.numHour.Name = "numHour";
            this.numHour.Size = new System.Drawing.Size(60, 21);
            this.numHour.TabIndex = 1;
            this.numHour.ValueChanged += new System.EventHandler(this.Numeric_ValueChanged);
            // 
            // lblMinute
            // 
            this.lblMinute.AutoSize = true;
            this.lblMinute.Location = new System.Drawing.Point(130, 34);
            this.lblMinute.Name = "lblMinute";
            this.lblMinute.Size = new System.Drawing.Size(17, 12);
            this.lblMinute.TabIndex = 2;
            this.lblMinute.Text = "分";
            // 
            // numMinute
            // 
            this.numMinute.Location = new System.Drawing.Point(154, 30);
            this.numMinute.Maximum = new decimal(new int[] {60, 0, 0, 0});
            this.numMinute.Name = "numMinute";
            this.numMinute.Size = new System.Drawing.Size(60, 21);
            this.numMinute.TabIndex = 3;
            this.numMinute.ValueChanged += new System.EventHandler(this.Numeric_ValueChanged);
            // 
            // lblSecond
            // 
            this.lblSecond.AutoSize = true;
            this.lblSecond.Location = new System.Drawing.Point(240, 34);
            this.lblSecond.Name = "lblSecond";
            this.lblSecond.Size = new System.Drawing.Size(17, 12);
            this.lblSecond.TabIndex = 4;
            this.lblSecond.Text = "秒";
            // 
            // numSecond
            // 
            this.numSecond.Location = new System.Drawing.Point(264, 30);
            this.numSecond.Maximum = new decimal(new int[] {60, 0, 0, 0});
            this.numSecond.Name = "numSecond";
            this.numSecond.Size = new System.Drawing.Size(60, 21);
            this.numSecond.TabIndex = 5;
            this.numSecond.ValueChanged += new System.EventHandler(this.Numeric_ValueChanged);
            // 
            // lblTarget
            // 
            this.lblTarget.AutoSize = true;
            this.lblTarget.Location = new System.Drawing.Point(20, 68);
            this.lblTarget.Name = "lblTarget";
            this.lblTarget.Size = new System.Drawing.Size(113, 12);
            this.lblTarget.TabIndex = 6;
            this.lblTarget.Text = "目标时刻：--:--:--";
            // 
            // lblNow
            // 
            this.lblNow.AutoSize = true;
            this.lblNow.Location = new System.Drawing.Point(16, 170);
            this.lblNow.Name = "lblNow";
            this.lblNow.Size = new System.Drawing.Size(113, 12);
            this.lblNow.TabIndex = 3;
            this.lblNow.Text = "当前时间：--:--:--";
            // 
            // lblRemain
            // 
            this.lblRemain.AutoSize = true;
            this.lblRemain.ForeColor = System.Drawing.Color.FromArgb(((int)(((byte)(180)))), ((int)(((byte)(60)))), ((int)(((byte)(40)))));
            this.lblRemain.Location = new System.Drawing.Point(16, 198);
            this.lblRemain.Name = "lblRemain";
            this.lblRemain.Size = new System.Drawing.Size(71, 12);
            this.lblRemain.TabIndex = 4;
            this.lblRemain.Text = "剩余：-- 秒";
            // 
            // btnStart
            // 
            this.btnStart.Location = new System.Drawing.Point(16, 232);
            this.btnStart.Name = "btnStart";
            this.btnStart.Size = new System.Drawing.Size(120, 34);
            this.btnStart.TabIndex = 5;
            this.btnStart.Text = "启动(&S)";
            this.btnStart.UseVisualStyleBackColor = true;
            this.btnStart.Click += new System.EventHandler(this.btnStart_Click);
            // 
            // btnCancel
            // 
            this.btnCancel.Enabled = false;
            this.btnCancel.Location = new System.Drawing.Point(152, 232);
            this.btnCancel.Name = "btnCancel";
            this.btnCancel.Size = new System.Drawing.Size(120, 34);
            this.btnCancel.TabIndex = 6;
            this.btnCancel.Text = "取消(&C)";
            this.btnCancel.UseVisualStyleBackColor = true;
            this.btnCancel.Click += new System.EventHandler(this.btnCancel_Click);
            // 
            // btnExit
            // 
            this.btnExit.Location = new System.Drawing.Point(288, 232);
            this.btnExit.Name = "btnExit";
            this.btnExit.Size = new System.Drawing.Size(120, 34);
            this.btnExit.TabIndex = 7;
            this.btnExit.Text = "退出(&X)";
            this.btnExit.UseVisualStyleBackColor = true;
            this.btnExit.Click += new System.EventHandler(this.btnExit_Click);
            // 
            // lblHint
            // 
            this.lblHint.ForeColor = System.Drawing.Color.DimGray;
            this.lblHint.Location = new System.Drawing.Point(16, 282);
            this.lblHint.Name = "lblHint";
            this.lblHint.Size = new System.Drawing.Size(556, 44);
            this.lblHint.TabIndex = 8;
            this.lblHint.Text = "到点后将自动打开系统默认浏览器访问上方网址；启动后时刻输入会被锁定，取消后才能修改。";
            // 
            // displayTimer
            // 
            this.displayTimer.Interval = 500;
            this.displayTimer.Tick += new System.EventHandler(this.displayTimer_Tick);
            // 
            // triggerTimer
            // 
            this.triggerTimer.Interval = 500;
            this.triggerTimer.Tick += new System.EventHandler(this.triggerTimer_Tick);
            // 
            // TimerForm
            // 
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.None;
            this.ClientSize = new System.Drawing.Size(600, 340);
            this.Controls.Add(this.lblUrl);
            this.Controls.Add(this.txtUrl);
            this.Controls.Add(this.gbTarget);
            this.Controls.Add(this.lblNow);
            this.Controls.Add(this.lblRemain);
            this.Controls.Add(this.btnStart);
            this.Controls.Add(this.btnCancel);
            this.Controls.Add(this.btnExit);
            this.Controls.Add(this.lblHint);
            this.Font = new System.Drawing.Font("Microsoft YaHei UI", 9F);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedSingle;
            this.MaximizeBox = false;
            this.Name = "TimerForm";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Text = "定时访问 — 3240704204";
            this.gbTarget.ResumeLayout(false);
            this.gbTarget.PerformLayout();
            ((System.ComponentModel.ISupportInitialize)(this.numHour)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numMinute)).EndInit();
            ((System.ComponentModel.ISupportInitialize)(this.numSecond)).EndInit();
            this.ResumeLayout(false);
            this.PerformLayout();
        }

        #endregion

        private System.Windows.Forms.Label lblUrl;
        private System.Windows.Forms.TextBox txtUrl;
        private System.Windows.Forms.GroupBox gbTarget;
        private System.Windows.Forms.Label lblHour;
        private System.Windows.Forms.NumericUpDown numHour;
        private System.Windows.Forms.Label lblMinute;
        private System.Windows.Forms.NumericUpDown numMinute;
        private System.Windows.Forms.Label lblSecond;
        private System.Windows.Forms.NumericUpDown numSecond;
        private System.Windows.Forms.Label lblTarget;
        private System.Windows.Forms.Label lblNow;
        private System.Windows.Forms.Label lblRemain;
        private System.Windows.Forms.Button btnStart;
        private System.Windows.Forms.Button btnCancel;
        private System.Windows.Forms.Button btnExit;
        private System.Windows.Forms.Label lblHint;
        private System.Windows.Forms.Timer displayTimer;
        private System.Windows.Forms.Timer triggerTimer;
    }
}
