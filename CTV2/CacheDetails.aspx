<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CacheDetails.aspx.cs" 
    Inherits="sitecore.admin.CacheTunerV2.CacheDetails" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <title>Cache Tuner V2 : Cache Details</title>
    <link type="text/css" href="cachetunerv2.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <table id="tableData" cellspacing="1" cellpadding="1" border="1" class="data">
            <tr>
                <td style="height: 36px" align="center">
                    <div id="shortnotice">
                        <asp:Literal ID="litMessage" runat="server" Visible="false"></asp:Literal>
                    </div>
                </td>
            </tr>
            <tr>
                <td align="right">
                    <asp:Button ID="btnClear" runat="server" Text="Clear Me!" CssClass="button"
                        OnClientClick="return confirm('Are you sure?');" OnClick="btnClear_Click"></asp:Button>
                </td>
            </tr>
            <tr>
                <td>
                    <div id="content">                        
                        <asp:Table runat="server" ID="tblCacheDetails"  CellPadding="0" CellSpacing="0"
                            CssClass="table table-bordered">
                            <asp:TableHeaderRow TableSection="TableHeader" CssClass="thead-dark">
                                <asp:TableHeaderCell>Key</asp:TableHeaderCell>
                                <asp:TableHeaderCell>Value</asp:TableHeaderCell>
                            </asp:TableHeaderRow>
                        </asp:Table>
                    </div>
                </td>
            </tr>
        </table>
    </form>
</body>
</html>
