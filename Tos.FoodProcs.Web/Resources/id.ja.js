(function () {

    App.ui.pagedata.lang("ja", {
        masterKubunId: { data: [{ id: "1", name: "品名マスタ" }, { id: "2", name: "配合マスタ"}] }
        , jotaiKubunId: { data: [{ id: "1", name: "固体" }, { id: "2", name: "液体" }, { id: "3", name: "仕掛品" }, { id: "9", name: "その他"}] }
        , hokanKubunId: { data: [{ id: "1", name: "常温" }, { id: "2", name: "冷蔵" }, { id: "3", name: "冷凍"}] }
        , yobiId: { data: [{ id: "0", name: "日曜日", shortName: "日" }, { id: "1", name: "月曜日", shortName: "月" }, { id: "2", name: "火曜日", shortName: "火" }, { id: "3", name: "水曜日", shortName: "水" }, { id: "4", name: "木曜日", shortName: "木" }, { id: "5", name: "金曜日", shortName: "金" }, { id: "6", name: "土曜日", shortName: "土"}] }
        , yobiHidukeId: { data: [{ id: "0", name: "{0}(日)" }, { id: "1", name: "{0}(月)" }, { id: "2", name: "{0}(火)" }, { id: "3", name: "{0}(水)" }, { id: "4", name: "{0}(木)" }, { id: "5", name: "{0}(金)" }, { id: "6", name: "{0}(土)"}] }
        , kuraireId: { data: [{ id: "1", name: "即庫入" }, { id: "2", name: "未包装" }, { id: "3", name: "庫入なし"}] }
        , nonyushoId: { data: [{ id: "0", name: "" }, { id: 1, name: "納入数量" }, { id: 2, name: "使用数量"}] }
        , kanzanKubunId: { data: [{ id: "4", name: "Ｋｇ" }, { id: "11", name: "Ｌ"}] }
        , gassanKubunId: { data: [{ id: "0", name: "なし" }, { id: "1", name: "合算"}] }
        // 上が旧権限、下が新権限
        //, kengenKubunId: { data: [{ id: "Admin", name: "管理者" }, { id: "Editor", name: "製造作業者" }, { id: "Operator", name: "入力作業者" }, { id: "Viewer", name: "閲覧者"}] }
        , kengenKubunId: { data: [{ id: "Admin", name: "管理者" }, { id: "Manufacture", name: "製造者" }, { id: "Purchase", name: "購買担当者" }, { id: "Quality", name: "品管担当者" }, { id: "Warehouse", name: "荷受担当者"}] }
        , monthNameId: { data: [{ id: 0, name: "1月", shortName: "1月" }, { id: 1, name: "2月", shortName: "2月" }, { id: 2, name: "3月", shortName: "3月" }, { id: 3, name: "4月", shortName: "4月" }, { id: 4, name: "5月", shortName: "5月" }, { id: 5, name: "6月", shortName: "6月" }, { id: 6, name: "7月", shortName: "7月" }, { id: 7, name: "8月", shortName: "8月" }, { id: 8, name: "9月", shortName: "9月" }, { id: 9, name: "10月", shortName: "10月" }, { id: 10, name: "11月", shortName: "11月" }, { id: 11, name: "12月", shortName: "12月"}] }
        , tenkaiKubunId: { data: [{ id: 0, name: "しない" }, { id: 1, name: "する"}] }
        , riyuBunruiKubunId: { data: [{ id: 1, name: "調整理由" }, { id: 2, name: "休日理由"}] }
        , dateFormatId: { data: [{ id: 0, number: 4 }, { id: 1, number: 2 }, { id: 2, number: 2}] }
        , nyukoKunbunId: { data: [{ id: 1, name: "有償" }, { id: 7, name: "無償"}] }
        , densoKunbunId: { data: [{ id: 1, name: "新規" }, { id: 2, name: "変更" }, { id: 3, name: "削除"}] }
        // ■仕掛残計上機能OFF対応(機能ONは下のコメントアウトをオープンして下さい):リストボックスから削除
        , anbunKubunId: { data: [{ id: 1, name: "製造" }, { id: 2, name: "調整"}/*, { id: 3, name: "残"}*/] }
        , densoJotaiId: { data: [{ id: 0, name: "未作成" }, { id: 1, name: "未伝送" }, { id: 2, name: "伝送待" }, { id: 3, name: "伝送中" }, { id: 4, name: "伝送済"}] }
        , torokuJotaiId: { data: [{ id: 0, name: "未登録" }, { id: 1, name: "一部未登録" }, { id: 2, name: "登録済"}] }
        // 最終行はカンマ不要
        //---------------------------------------------------------
        //2019/07/23 trinh.bd Task #14029
        //------------------------START----------------------------
        , roleNewId: { data: [{ id: 0, name: "" }, { id: 1, name: "参照" }, { id: 2, name: "更新"}] }
        //-------------------------END-----------------------------
    });

})();

