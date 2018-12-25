<%@ Page Language="C#" AutoEventWireup="true" Debug="true" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN" >
<%@ Import Namespace="System" %>
<%@ Import Namespace="System.Collections" %>
<%@ Import Namespace="System.Collections.Generic" %>
<%@ Import Namespace="System.Configuration" %>
<%@ Import Namespace="System.Data" %>
<%@ Import Namespace="System.Web" %>
<%@ Import Namespace="System.Web.Security" %>
<%@ Import Namespace="System.Web.UI" %>
<%@ Import Namespace="System.Web.UI.HtmlControls" %>
<%@ Import Namespace="System.Web.UI.WebControls" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="Sitecore.Configuration" %>
<%--Author : Kiran Patil
Version : 1.1.0.0--%>

<script language="C#" runat="server">   
    
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
                    description = @"Time to tune this cache! Reason : 80% exceeded. New Cache Size should be (following 50 % Increment rule)
                :" + Sitecore.StringUtil.GetSizeString((maxSize + (maxSize * 50) / 100)) + ". % of Usage : " + thresholdValue.ToString();

                }
                // OR If Delta value changes
                else if (size != @int)
                {
                    severityLevel = "ALERT";
                    description = @"Time to tune this cache! Reason : Delta fluctuation. New Cache Size should be (following 50 % Increment rule)
                :" + Sitecore.StringUtil.GetSizeString((maxSize + (maxSize * 50) / 100)) + ". % of Usage : " + thresholdValue.ToString();
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

            // Add Row data
            HtmlTableRow row = Sitecore.Web.HtmlUtil.AddRow(table,
                new string[] { string.Empty, cache.Name, 
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
    

</script>

<html>
<head>
    <title>Cache Tuner</title>
    <meta content="Microsoft Visual Studio .NET 7.1" name="GENERATOR">
    <meta content="C#" name="CODE_LANGUAGE">
    <meta content="JavaScript" name="vs_defaultClientScript">
    <meta content="http://schemas.microsoft.com/intellisense/ie5" name="vs_targetSchema">
    <style type="text/css">
        body
        {
            font-size: medium;
            color: #000;
            font-family: "Lucida Grande" , "Calibri" , helvetica, sans-serif;
            scrollbar-3dlight-color: #DDEAF9;
            scrollbar-arrow-color: #1C3C82;
            scrollbar-base-color: #DDEAF9;
            scrollbar-darkshadow-color: #DDEAF9;
            scrollbar-face-color: #DDEAF9;
            scrollbar-highlight-color: black;
            scrollbar-shadow-color: black;
            font-size: small;
            background: #F7F7F7 none repeat scroll 0 0;
        }
        .button
        {
            -moz-border-radius-bottomleft: 7px;
            -moz-border-radius-bottomright: 7px;
            -moz-border-radius-topleft: 7px;
            -moz-border-radius-topright: 7px;
            background-color: #DDEAF9;
            border: 1px solid #AAB7C6;
            display: inline-block;
            margin: 0 5px 10px 0;
            padding: 3px;
            border-color: darkgreen;
        }
        .data
        {
            border-collapse: collapse;
            margin: 10px 0 0;
            width: 100%;
            border-color: darkgreen;
        }
        .data td
        {
            border: 1px solid darkgreen;
            padding: 5px;
        }
        #content
        {
            -moz-border-radius-bottomleft: 7px;
            -moz-border-radius-bottomright: 7px;
            -moz-border-radius-topleft: 7px;
            -moz-border-radius-topright: 7px;
            background-color: #FFFFFF;
            border: 2px solid #FFFFFF;
            color: black;
            line-height: 1.5em;
        }
        #shortnotice
        {
            background-color: #FFDDDD;
            border: 1px solid #FFDDDD;
            font-weight: bold;
            width: 97%;
        }
    </style>
</head>
<body>
    <form id="Form1" method="post" runat="server">
    <table id="tableData" cellspacing="1" cellpadding="1" border="1" class="data">
        <tr>
            <td style="height: 36px" colspan="3" align="center">
                <div id="shortnotice">
                    Just a note : Delta fluctuation will always come first time. So, you can just ignore
                    it first time!</div>
            </td>
        </tr>
        <tr>
            <td align="right">
                <asp:Button ID="btnrefresh" runat="server" Text="Refresh" CssClass="button"></asp:Button>
                <asp:Button ID="btnDownloadCSV" runat="server" Text="Export to CSV" Visible="true"
                    CssClass="button" Enabled="false"></asp:Button>
            </td>
        </tr>
        <tr>
            <td>
                <div id="content">
                    <table runat="server" id="tblCacheStats" border="1" width="100%" cellpadding="4"
                        class="data">
                    </table>
                </div>
            </td>
        </tr>
    </table>
    </form>
</body>
</html>
