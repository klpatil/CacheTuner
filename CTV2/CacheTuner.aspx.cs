using System;
using System.Text;
using System.Web.UI;
using System.Web.UI.HtmlControls;

namespace sitecore.admin.CacheTunerV2
{
    public partial class Default : System.Web.UI.Page
    {
        /// <summary>
        /// Total of Max Size
        /// </summary>
        public long MaxSizeTotal
        {
            get { return (ViewState["maxSizeTotal"] == null) ? 0 : Convert.ToInt64(ViewState["maxSizeTotal"]); }
            set { ViewState["maxSizeTotal"] = value; }
        }

        /// <summary>
        ///  Total of Delta
        /// </summary>
        public long DeltaTotal
        {
            get { return (ViewState["DeltaTotal"] == null) ? 0 : Convert.ToInt64(ViewState["DeltaTotal"]); }
            set { ViewState["DeltaTotal"] = value; }
        }

        /// <summary>
        /// Total of Count
        /// </summary>
        public long CountTotal
        {
            get { return (ViewState["CountTotal"] == null) ? 0 : Convert.ToInt64(ViewState["CountTotal"]); }
            set { ViewState["CountTotal"] = value; }
        }

        private void InitializeComponent()
        {
            this.btnrefresh.Click += new EventHandler(this.btnrefresh_Click);
            this.btnDownloadCSV.Click += new EventHandler(this.btnDownloadCSV_Click);
            this.btnclearAll.Click += new EventHandler(this.btnclearAll_Click);
            base.Load += new EventHandler(this.Page_Load);
        }

        protected override void OnInit(EventArgs e)
        {
            this.InitializeComponent();
            base.OnInit(e);
        }

        /// <summary>
        /// This function will be used
        /// to be get called on page_load
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void Page_Load(object sender, EventArgs e)
        {
        }


        /// <param name="e">EventArgs</param>
        private void btnclearAll_Click(object sender, EventArgs e)
        {
            try
            {
                Sitecore.Caching.CacheManager.ClearAllCaches();
            }
            catch (Exception ex)
            {
                Response.Write(ex.ToString());
            }
        }
        /// <summary>
        /// This function will be used to
        /// Refresh data
        /// </summary>
        /// <param name="sender">Button</param>
        /// <param name="e">EventArgs</param>
        private void btnrefresh_Click(object sender, EventArgs e)
        {
            try
            {
                // Disable CSV Download
                btnDownloadCSV.Enabled = true;
                // Reset Cache List
                this.ResetCacheList();
            }
            catch (Exception ex)
            {
                Response.Write(ex.ToString());
            }
        }

        /// <summary>
        /// This function will be used to download CSV
        /// </summary>
        /// <param name="sender">Button</param>
        /// <param name="e">EventArgs</param>
        private void btnDownloadCSV_Click(object sender, EventArgs e)
        {
            try
            {
                Response.Clear();
                Response.Buffer = true;
                Response.AddHeader("content-disposition", "attachment;filename=Cache_Tuning_Suggestion"
                    + DateTime.Now.ToString("dd_MM_yyyy_HH_mm_ss") + ".csv");
                Response.Charset = "";
                Response.ContentType = "application/text";

                StringBuilder sb = new StringBuilder();

                // Headers
                sb.Append("Name,");
                sb.Append("Count,");
                sb.Append("Size,");
                sb.Append("Delta,");
                sb.Append("MaxSize,");
                sb.Append("Severity,"); sb.Append("Suggestion");

                //append new line
                sb.Append("\r\n");

                Sitecore.Caching.ICacheInfo[] allCaches = Sitecore.Caching.CacheManager.GetAllCaches();
                Array.Sort(allCaches, new Sitecore.Caching.CacheComparer());

                // Reset counters
                CountTotal = 0;
                DeltaTotal = 0;
                MaxSizeTotal = 0;

                foreach (Sitecore.Caching.ICacheInfo cache in allCaches)
                {
                    string str = "size_" + cache.Id.ToShortID();
                    long @int = Sitecore.MainUtil.GetInt(base.Request.Form[str], 0);
                    long count = cache.Count;
                    CountTotal += count;

                    long size = cache.Size;
                    long maxSize = cache.MaxSize;
                    // Sum of Max Size
                    MaxSizeTotal += maxSize;

                    long delta = size - @int;
                    DeltaTotal += delta;

                    double thresholdValue = 0;
                    if (maxSize > 0)
                        thresholdValue = ((double)size / (double)maxSize) * 100;

                    string severityLevel = "NORMAL";
                    string description = "NA";

                    // If ThresholdValue is grater than 80%
                    // OR If Delta value changes
                    // It's an ALERT
                    // It's an ALERT
                    if (thresholdValue > 80)
                    {
                        severityLevel = "ALERT";
                        description = @"Time to tune this cache! Reason : 80% exceeded. New Cache Size should be (following 50 % Increment rule):" + Sitecore.StringUtil.GetSizeString((maxSize + (maxSize * 50) / 100)) + ". % of Usage : " + thresholdValue.ToString();
                    }
                    // OR If Delta value changes
                    else if (size != @int)
                    {
                        severityLevel = "ALERT";
                        description = @"Time to tune this cache! Reason : Delta fluctuation. New Cache Size should be (following 50 % Increment rule):" + Sitecore.StringUtil.GetSizeString((maxSize + (maxSize * 50) / 100)) + ". % of Usage : " + thresholdValue.ToString();
                    }
                    else if (thresholdValue >= 50)
                    {
                        severityLevel = "WARNING";
                        description = "50% of this cache is being utilized. Its not a big reason to worry. But good to keep an eye on this.";
                    }
                    else
                    {
                        severityLevel = "NORMAL";
                    }

                    sb.Append(cache.Name);
                    sb.Append(",");
                    sb.Append(count.ToString());
                    sb.Append(",");
                    sb.Append(Sitecore.StringUtil.GetSizeString(size));
                    sb.Append(",");
                    sb.Append(Sitecore.StringUtil.GetSizeString(delta));
                    sb.Append(",");
                    sb.Append(Sitecore.StringUtil.GetSizeString(maxSize));
                    sb.Append(",");
                    sb.Append(severityLevel);
                    sb.Append(",");
                    sb.Append(description);

                    //append new line
                    sb.Append("\r\n");
                }

                // Final line -- for summary and total data
                Sitecore.Caching.CacheStatistics statistics = Sitecore.Caching.CacheManager.GetStatistics();

                sb.Append("Total");
                sb.Append(",");
                sb.Append(CountTotal.ToString());
                sb.Append(",");
                sb.Append(Sitecore.StringUtil.GetSizeString(statistics.TotalSize));
                sb.Append(",");
                sb.Append(Sitecore.StringUtil.GetSizeString(DeltaTotal));
                sb.Append(",");
                sb.Append(Sitecore.StringUtil.GetSizeString(MaxSizeTotal));
                sb.Append(",");
                sb.Append("NA");
                sb.Append(",");
                sb.Append("NA");

                //append new line
                sb.Append("\r\n");

                Response.Output.Write(sb.ToString());
                Response.Flush();

                Response.End();
            }
            catch (System.Threading.ThreadAbortException)
            {
                // Ignore this exception
            }
            catch (Exception ex)
            {
                Response.Write(ex.ToString());
            }
        }

        /// <summary>
        /// This function will be used to
        /// Reset Cache List
        /// </summary>
        private void ResetCacheList()
        {
            Sitecore.Caching.ICacheInfo[] allCaches = Sitecore.Caching.CacheManager.GetAllCaches();
            Array.Sort(allCaches, new Sitecore.Caching.CacheComparer());

            HtmlTable table = tblCacheStats;

            Sitecore.Web.HtmlUtil.AddRow(table, new string[] { string.Empty, "Name", "Count", "Size", "Delta", "MaxSize",
            "Severity","Suggestion" });
            table.Rows[0].Style.Add(HtmlTextWriterStyle.BackgroundColor, "#DDEAF9");
            table.Rows[0].Style.Add(HtmlTextWriterStyle.Color, "black");
            table.Rows[0].Style.Add(HtmlTextWriterStyle.BorderCollapse, "collapse");
            table.Rows[0].Style.Add("border", "1px solid red");
            table.Rows[0].Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            table.Rows[0].Style.Add(HtmlTextWriterStyle.FontWeight, "bold");

            //table.Rows[0].Cells[0].Style.Add(HtmlTextWriterStyle.Visibility, "hidden");

            // Reset counters
            CountTotal = 0;
            DeltaTotal = 0;
            MaxSizeTotal = 0;

            foreach (Sitecore.Caching.ICacheInfo cache in allCaches)
            {
                string str = "size_" + cache.Id.ToShortID();
                long @int = Sitecore.MainUtil.GetInt(base.Request.Form[str], 0);
                long count = cache.Count;
                CountTotal += count;
                long size = cache.Size;

                long maxSize = cache.MaxSize;
                // Sum of Max Size
                MaxSizeTotal += maxSize;

                long delta = size - @int;
                DeltaTotal += delta;

                double thresholdValue = 0;
                if (maxSize > 0)
                    thresholdValue = ((double)size / (double)maxSize) * 100;

                string severityLevel = "NORMAL";
                string description = "NA";
                string backGroundColor = "white";

                // If ThresholdValue is grater than 80%

                // It's an ALERT
                if (thresholdValue > 80)
                {
                    severityLevel = "ALERT";
                    description = @"Time to tune this cache! Reason : 80% exceeded. New Cache Size should be (following 50 % Increment rule)
                :" + Sitecore.StringUtil.GetSizeString((maxSize + (maxSize * 50) / 100)) + ". % of Usage : " + thresholdValue.ToString();
                    backGroundColor = "red";
                }
                // OR If Delta value changes
                else if (size != @int)
                {
                    severityLevel = "ALERT";
                    description = @"Time to tune this cache! Reason : Delta fluctuation. New Cache Size should be (following 50 % Increment rule)
                :" + Sitecore.StringUtil.GetSizeString((maxSize + (maxSize * 50) / 100)) + ". % of Usage : " + thresholdValue.ToString();
                    backGroundColor = "red";
                }
                else if (thresholdValue >= 50)
                {
                    severityLevel = "WARNING";
                    description = "50% of this cache is being utilized. Its not a big reason to worry. But good to keep an eye on this.";
                    backGroundColor = "orange";
                }
                else
                {
                    severityLevel = "NORMAL";
                    backGroundColor = "lightgreen";
                }

                string cacheNameWithLink = string.Empty;

                if (count > 0)
                {
                    cacheNameWithLink =
                        string.Format("<a href='cachedetails.aspx?cachekey={0}' target='_blank'>{1}</a>",
                        cache.Name, cache.Name);
                }
                else
                {
                    cacheNameWithLink = cache.Name;
                }

                // Add Row data
                HtmlTableRow row = Sitecore.Web.HtmlUtil.AddRow(table,
                    new string[] { string.Empty, cacheNameWithLink,
                    count.ToString(),
                    Sitecore.StringUtil.GetSizeString(size),
                    Sitecore.StringUtil.GetSizeString(delta),
                    Sitecore.StringUtil.GetSizeString(maxSize),
                    severityLevel,
                    description});

                // 3rd and 4th column should be righ aligned
                for (int i = 2; i < row.Cells.Count; i++)
                {
                    row.Cells[i].Align = "right";
                    // We just need Count Size and Delta to
                    // be right aligned
                    if (i == 5)
                        break;
                }

                row.BgColor = backGroundColor;

                // Hidden Cache Size -- for delta value
                HtmlInputHidden child = new HtmlInputHidden();
                child.ID = str;
                child.Value = size.ToString();
                row.Cells[0].Controls.Add(child);
            }

            this.UpdateTotals(allCaches);
        }

        /// <summary>
        /// This function will be used
        /// to Update Totals
        /// </summary>
        /// <param name="allCaches">All Caches</param>
        private void UpdateTotals(Sitecore.Caching.ICacheInfo[] allCaches)
        {
            Sitecore.Caching.CacheStatistics statistics = Sitecore.Caching.CacheManager.GetStatistics();
            HtmlTableRow row = Sitecore.Web.HtmlUtil.AddRow(tblCacheStats,
                    new string[] { string.Empty, "<strong>Total</strong>",
                    "<strong>"+CountTotal.ToString()+"</strong>",
                    "<strong>"+Sitecore.StringUtil.GetSizeString(statistics.TotalSize)+"</strong>",
                    "<strong>"+Sitecore.StringUtil.GetSizeString(DeltaTotal)+"</strong>",
                    "<strong>"+Sitecore.StringUtil.GetSizeString(MaxSizeTotal)+"</strong>",
                    "<strong>NA</strong>",
                    "<strong>NA</strong>"});

            row.Style.Add(HtmlTextWriterStyle.BackgroundColor, "#DDEAF9");
            row.Style.Add(HtmlTextWriterStyle.Color, "black");
            row.Style.Add(HtmlTextWriterStyle.BorderCollapse, "collapse");
            row.Style.Add("border", "1px solid red");
            row.Style.Add(HtmlTextWriterStyle.TextAlign, "center");
            row.Style.Add(HtmlTextWriterStyle.FontWeight, "bold");
        }
    }
}