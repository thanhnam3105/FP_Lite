(function () {

    App.ui.pagedata.lang("zh", {
        masterKubunId: { data: [{ id: "1", name: "品名主表" }, { id: "2", name: "配料主表"}] }
        , jotaiKubunId: { data: [{ id: "1", name: "固体" }, { id: "2", name: "液体" }, { id: "3", name: "半成品" }, { id: "9", name: "其它"}] }
        , hokanKubunId: { data: [{ id: "1", name: "常温" }, { id: "2", name: "冷藏" }, { id: "3", name: "冷冻"}] }
        //, yobiId: { data: [{ id: "0", name: "星期日", shortName: "星期日" }, { id: "1", name: "星期一", shortName: "星期一" }, { id: "2", name: "星期二", shortName: "星期二" }, { id: "3", name: "星期三", shortName: "星期三" }, { id: "4", name: "星期四", shortName: "星期四" }, { id: "5", name: "星期五", shortName: "星期五" }, { id: "6", name: "星期六", shortName: "星期六"}] }
        , yobiId: { data: [{ id: "0", name: "星期日", shortName: "日" }, { id: "1", name: "星期一", shortName: "一" }, { id: "2", name: "星期二", shortName: "二" }, { id: "3", name: "星期三", shortName: "三" }, { id: "4", name: "星期四", shortName: "四" }, { id: "5", name: "星期五", shortName: "五" }, { id: "6", name: "星期六", shortName: "六"}] }
        , yobiHidukeId: { data: [{ id: "0", name: "{0}(星期日)" }, { id: "1", name: "{0}(星期一)" }, { id: "2", name: "{0}(星期二)" }, { id: "3", name: "{0}(星期三)" }, { id: "4", name: "{0}(星期四)" }, { id: "5", name: "{0}(星期五)" }, { id: "6", name: "{0}(星期六)"}] }
        , kuraireId: { data: [{ id: "1", name: "即时入库" }, { id: "2", name: "未包装" }, { id: "3", name: "无入库"}] }
        , nonyushoId: { data: [{ id: "0", name: "" }, { id: 1, name: "入库数量" }, { id: 2, name: "使用数量"}] }
        , kanzanKubunId: { data: [{ id: "4", name: "Ｋｇ" }, { id: "11", name: "Ｌ"}] }
        , gassanKubunId: { data: [{ id: "0", name: "无" }, { id: "1", name: "合算"}] }
        // 上が旧権限、下が新権限
        //, kengenKubunId: { data: [{ id: "Admin", name: "管理者" }, { id: "Editor", name: "编者" }, { id: "Operator", name: "操作者" }, { id: "Viewer", name: "阅览者"}] }
        //, kengenKubunId: { data: [{ id: "Admin", name: "管理者" }, { id: "Manufacture", name: "生产担当者" }, { id: "Purchase", name: "购买担当者" }, { id: "Quality", name: "品质管理担当者" }, { id: "Warehouse", name: "入库担当者"}] }
        , kengenKubunId: { data: [{ id: "Admin", name: "管理者" }, { id: "Manufacture", name: "生产担当者" }, { id: "Purchase", name: "购买担当者" }, { id: "Quality", name: "品质管理担当者" }, { id: "Warehouse", name: "入库担当者"}] }
        , monthNameId: { data: [{ id: 0, name: "1月", shortName: "1月" }, { id: 1, name: "2月", shortName: "2月" }, { id: 2, name: "3月", shortName: "3月" }, { id: 3, name: "4月", shortName: "4月" }, { id: 4, name: "5月", shortName: "5月" }, { id: 5, name: "6月", shortName: "6月" }, { id: 6, name: "7月", shortName: "7月" }, { id: 7, name: "8月", shortName: "8月" }, { id: 8, name: "9月", shortName: "9月" }, { id: 9, name: "10月", shortName: "10月" }, { id: 10, name: "11月", shortName: "11月" }, { id: 11, name: "12月", shortName: "12月"}] }
        , tenkaiKubunId: { data: [{ id: 0, name: "不进行" }, { id: 1, name: "进行"}] }
        , riyuBunruiKubunId: { data: [{ id: 1, name: "调整理由" }, { id: 2, name: "假日理由"}] }
        , dateFormatId: { data: [{ id: 0, number: 4 }, { id: 1, number: 2 }, { id: 2, number: 2}] }
        , nyukoKunbunId: { data: [{ id: 1, name: "有偿" }, { id: 7, name: "无偿"}] }
        , densoKunbunId: { data: [{ id: 1, name: "新建" }, { id: 2, name: "变更" }, { id: 3, name: "删除"}] }
        // ■仕掛残計上機能OFF対応(機能ONは下のコメントアウトをオープンして下さい):リストボックスから削除
        , anbunKubunId: { data: [{ id: 1, name: "生产" }, { id: 2, name: "调整" }/*, { id: 3, name: "残"}*/] }
        , densoJotaiId: { data: [{ id: 0, name: "未制作" }, { id: 1, name: "未传送" }, { id: 2, name: "等传送" }, { id: 3, name: "传送中" }, { id: 4, name: "已传送"}] }
        , torokuJotaiId: { data: [{ id: 0, name: "未登录" }, { id: 1, name: "一部未登录" }, { id: 2, name: "已登录"}] }
        // 最終行はカンマ不要
        //---------------------------------------------------------
        //2019/07/23 trinh.bd Task #14029
        //------------------------START----------------------------
        , roleNewId: { data: [{ id: 0, name: "" }, { id: 1, name: "参考" }, { id: 2, name: "更新" }] }
        //-------------------------END-----------------------------
    });

})();
