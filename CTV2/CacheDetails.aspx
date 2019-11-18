<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CacheDetails.aspx.cs" Inherits="sitecore.admin.CacheTunerV2.CacheDetails" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" lang="en">

<head runat="server">
    <title>Sitecore Cache Tuner V2 : Cache Details</title>
    <link href="tailwind.min.css" rel="stylesheet">
</head>

<body>
    <form id="form1" runat="server">
        <div class="my-4 mx-2">
            <h1 class="text-3xl font-bold">Sitecore Cache Tuner V2 : Cache Details</h1>
        </div>
        <div class="text-left my-4 mx-2">
            <asp:Button ID="btnClear" runat="server" Text="Clear Me!"
                CssClass="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded"
                OnClientClick="return confirm('Are you sure?');" OnClick="btnClear_Click"></asp:Button>
        </div>
        <div id="shortnotice"
            class="bg-red-100 border border-red-400 text-red-700 text-left px-4 py-3 my-4 mx-2 rounded relative"
            role="alert">
            <strong class="font-bold">
                <asp:Literal ID="litMessage" runat="server" Visible="false"></asp:Literal>
            </strong>
        </div>
        <div class="mx-2 my-4 text-center">
            <asp:Table runat="server" ID="tblCacheDetails" CssClass="table-auto" Width="100%">
                <asp:TableHeaderRow TableSection="TableHeader"
                    CssClass="bg-gray-100 font-bold text-left border rounded">
                    <asp:TableHeaderCell CssClass="px-4 py-2 border">Key</asp:TableHeaderCell>
                    <asp:TableHeaderCell CssClass="px-4 py-2 border">Value</asp:TableHeaderCell>
                </asp:TableHeaderRow>
            </asp:Table>
        </div>
    </form>
</body>

</html>