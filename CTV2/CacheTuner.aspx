<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CacheTuner.aspx.cs" 
    Inherits="sitecore.admin.CacheTunerV2.Default" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Cache Tuner V2</title>
    <link type="text/css" href="cachetunerv2.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <table id="tableData" cellspacing="1" cellpadding="1" border="1" class="data">
            <tr>
                <td style="height: 36px" colspan="3" align="center">
                    <div id="shortnotice">
                        Just a note : Delta fluctuation will always come first time. So, you can just ignore
                    it first time!
                    </div>
                </td>
            </tr>
            <tr>
                <td align="right">
                    <asp:Button ID="btnrefresh" runat="server" Text="Refresh" CssClass="button"></asp:Button>
                    <asp:Button ID="btnDownloadCSV" runat="server" Text="Export to CSV" Visible="true"
                        CssClass="button" Enabled="false"></asp:Button>
                    <asp:Button ID="btnclearAll" Text="ClearAll" OnClientClick="return confirm('Are you sure?);"
                        runat="server" CssClass="button"></asp:Button>
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
