<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CacheTuner.aspx.cs" Inherits="sitecore.admin.CacheTunerV2.Default" %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">

<head runat="server">
    <title>Sitecore Cache Tuner V2</title>
    <link href="tailwind.min.css" rel="stylesheet">
</head>

<body>
    <form id="form1" runat="server">
        <div class="my-4 mx-2">
            <h1 class="text-3xl font-bold">Sitecore Cache Tuner V2</h1>
        </div>
        <div class="text-left my-4 mx-2">
            <asp:Button ID="btnrefresh" runat="server" Text="Refresh"
                CssClass="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded"></asp:Button>
            <asp:Button ID="btnDownloadCSV" runat="server" Text="Export to CSV" Visible="true"
                CssClass="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded" Enabled="false">
            </asp:Button>
            <asp:Button ID="btnclearAll" Text="Clear All" OnClientClick="return confirm('Are you sure?);" runat="server"
                CssClass="bg-green-500 hover:bg-green-700 text-white font-bold py-2 px-4 rounded"></asp:Button>
        </div>
        <div id="shortnotice"
            class="bg-red-100 border border-red-400 text-red-700 text-left px-4 py-3 my-4 mx-2 rounded relative"
            role="alert">
            <strong class="font-bold">Just a note : Delta fluctuation will always come first time. So, you can just
                ignore
                it first time!</strong>
        </div>
        <div class="mx-2 my-4 text-center">
            <table runat="server" id="tblCacheStats" class="table-auto" width="100%">
            </table>
        </div>
    </form>
</body>

</html>