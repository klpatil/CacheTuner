using Sitecore.Caching;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace sitecore.admin.CacheTunerV2
{
    public partial class CacheDetails : System.Web.UI.Page
    {
        public string CacheKey { get { return HttpContext.Current.Request.QueryString["cachekey"]; } }
        private void Page_Load(object sender, EventArgs e)
        {

            if (!string.IsNullOrWhiteSpace(CacheKey))
            {
                LoadCacheDetails(CacheKey);
            }
            else
            {
                ShowMessage("CacheKey not provided, Please provide cachekey value in Querystring", string.Empty);
            }
        }

        /// <summary>
        /// This function will be used to
        /// Reset Cache List
        /// </summary>
        private void LoadCacheDetails(string cacheKey)
        {
            // Get CacheKey and Value
            var cache = CacheManager.GetAllCaches().SingleOrDefault(c => c.Name == CacheKey);
            ICache aiCache = cache as ICache;
            if (aiCache != null)
            {
                var keys = aiCache.GetCacheKeys();
                foreach (var aKey in keys)
                {
                    TableRow tableRow = new TableRow();
                    tableRow.TableSection = TableRowSection.TableBody;
                    tableRow.CssClass = "text-left";

                    AddTableCell(tableRow, aKey);
                    AddTableCell(tableRow, Convert.ToString(aiCache.GetValue(aKey)));
                    tableRow.Cells[0].CssClass = "border bg-gray-100 py-2 px-4";
                    tableRow.Cells[1].CssClass = "border bg-gray-100 py-2 px-4";

                    tblCacheDetails.Rows.Add(tableRow);
                }

                ShowMessage(string.Format(@"Showing Total <strong>{0}</strong> Cache entries for Key <strong>{1}</strong>"
                    , aiCache.Count, cacheKey), string.Empty);
                litMessage.Visible = true;
                tblCacheDetails.Visible = true;
            }
            else
            {
                ShowMessage("We only show cache values which are of string type. But you can still clear that particular cache from this page.", string.Empty);
            }
        }

        /// <summary>
        /// This function will be used
        /// to show message
        /// </summary>
        /// <param name="message">Message to show</param>
        /// <param name="messageType">Message type to show</param>
        private void ShowMessage(string message, string messageType)
        {
            litMessage.Visible = true;
            litMessage.Text = message;
        }

        /// <summary>
        /// This function will be used to add
        /// table cell
        /// </summary>
        /// <param name="tableRow">Table Row</param>
        /// <param name="aField">Field</param>
        /// <param name="fieldType">Type of field</param>
        /// <returns></returns>
        private static TableCell AddTableCell(TableRow tableRow,
            string value)
        {
            TableCell tableCell1 = new TableCell();
            string valueToPrint = "NA";
            valueToPrint = !string.IsNullOrWhiteSpace(value) ? value : "NA";
            tableCell1.Text = valueToPrint;
            tableRow.Cells.Add(tableCell1);
            return tableCell1;
        }

        protected void btnClear_Click(object sender, EventArgs e)
        {
            try
            {
                var cache = CacheManager.GetAllCaches().SingleOrDefault(c => c.Name == CacheKey);
                if (cache != null)
                {
                    cache.Clear();
                    ShowMessage(CacheKey + " cleared.",string.Empty);
                }
                else
                {
                    ShowMessage(CacheKey + " not found.", string.Empty);
                }
            }
            catch (Exception ex)
            {
                string message = "Error occured during cache clearing : " + ex.Message;
                ShowMessage(message, string.Empty);
                Sitecore.Diagnostics.Log.Error(message, ex, this);
            }
        }
    }
}