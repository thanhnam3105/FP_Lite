
<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="TestDialog.aspx.cs" Inherits="Tos.FoodProcs.Web.Pages.TestDialog" %>

<asp:Content ID="Content1" ContentPlaceHolderID="IncludeContent" runat="server">
    <script src="<%=ResolveUrl("~/Resources/pages/pagedata-bommasterdensoichiran."+ System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
    <script src="<%=ResolveUrl("~/Resources/grid/grid.locale-"+ System.Threading.Thread.CurrentThread.CurrentUICulture.TwoLetterISOLanguageName + ".js") %>"
        type="text/javascript"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        .genryo-lot-torikeshi
        {
            background-color: White;
            width: 540px;
        }
        .jika-genryo-lot-torikeshi
        {
            background-color: White;
            width: 540px;
        }
    </style>
    <script type="text/javascript">
        $(App.ui.page).on("ready", function () {

            // 原料ロット選択ダイアログを呼びます。
            $("#btn-genryo-lot-sentaku").on("click", function () {
                var option = { id: 'genryoLotSentakuDialog' };
                genryoLotSentakuDialog.dlg("open", option);
                genryoLotSentakuDialog.draggable(true);
            });
            var genryoLotSentakuDialog = $(".genryo-lot-sentaku");
            genryoLotSentakuDialog.dlg({
                url: "Dialog/GenryoLotSentakuDialog.aspx",
                name: "GenryoLotSentakuDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                }
            });

            // 原料ロット取消ダイアログを呼びます。
            $("#btn-genryo-lot-torikeshi").on("click", function () {
                var option = { id: 'genryoLotTorikeshiDialog' };
                genryoLotTorikeshiDialog.dlg("open", option);
                genryoLotTorikeshiDialog.draggable(true);
            });
            var genryoLotTorikeshiDialog = $(".genryo-lot-torikeshi");
            genryoLotTorikeshiDialog.dlg({
                url: "Dialog/GenryoLotTorikeshiDialog.aspx",
                name: "GenryoLotTorikeshiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                }
            });

            // 原料ロット選択ダイアログを呼びます。
            $("#btn-jika-genryo-lot-sentaku").on("click", function () {
                var option = { id: 'jikaGenryoLotSentakuDialog', multiselect: false };
                jikaGenyoLotSentakuDialog.dlg("open", option);
                jikaGenyoLotSentakuDialog.draggable(true);
            });
            var jikaGenyoLotSentakuDialog = $(".jika-genryo-lot-sentaku");
            jikaGenyoLotSentakuDialog.dlg({
                url: "Dialog/JikaGenryoLotSentakuDialog.aspx",
                name: "JikaGenryoLotSentakuDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                }
            });

            // 自家原料ロット取消ダイアログを呼びます。
            $("#btn-jika-genryo-lot-torikeshi").on("click", function () {
                var option = { id: 'jika-genryo-lot-torikeshi' };
                jikaGenryoLotTorikeshiDialog.dlg("open", option);
                jikaGenryoLotTorikeshiDialog.draggable(true);
            });
            var jikaGenryoLotTorikeshiDialog = $(".jika-genryo-lot-torikeshi");
            jikaGenryoLotTorikeshiDialog.dlg({
                url: "Dialog/JikaGenryoLotTorikeshiDialog.aspx",
                name: "JikaGenryoLotTorikeshiDialog",
                closed: function (e, data, data2) {
                    if (data == "canceled") {
                        return;
                    }
                }
            });
        });
    </script>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="MainContent" runat="server">
    <div class="part-body">
        <div>            
            <button type="button" class="dialog-button" id="btn-genryo-lot-sentaku">原料ロット選択</button>
            <button type="button" class="dialog-button" id="btn-genryo-lot-torikeshi">原料ロット取消</button>
            <button type="button" class="dialog-button" id="btn-jika-genryo-lot-sentaku">自家原料ロット選択</button>
            <button type="button" class="dialog-button" id="btn-jika-genryo-lot-torikeshi">自家原料ロット取消</button>
        </div>
    </div> 
</asp:Content>

<asp:Content ID="Content4" ContentPlaceHolderID="FooterContent" runat="server">
    
</asp:Content>

<asp:Content ID="Content5" ContentPlaceHolderID="DialogsContent" runat="server">
    <div class="genryo-lot-sentaku"></div>
    <div class="genryo-lot-torikeshi"></div>
    <div class="jika-genryo-lot-sentaku"></div>    
    <div class="jika-genryo-lot-torikeshi"></div>
</asp:Content>
