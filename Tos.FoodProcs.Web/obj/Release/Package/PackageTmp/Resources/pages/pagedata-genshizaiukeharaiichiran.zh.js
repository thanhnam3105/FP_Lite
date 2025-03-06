(function () {
    var lang = App.ui.pagedata.lang("zh", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        //_pageTitle: { text: "原材料出货一览" },
        _pageTitle: { text: "原材料出入库一览" },

        // 検索条件
        dt_hiduke_search: { text: "日期" },
        between: { text: "　～　" },
        flg_mishiyobun: { text: "含有未使用" },
        ari_nomi: { text: "计算库存/只是有实际库存" },
        //hinKubun: { text: "品区分" },
        hinKubun: { text: "商品区分" },
        //hinBunrui: { text: "品分类" },
        hinBunrui: { text: "商品分类" },
        hinCode: { text: "原材料编号" },
        hinName: { text: "原材料名" },
        flg_today_jisseki: { text: "显示当天的实际" },
        ukeKubun: { text: "出入库区分" },

        // グリッド項目
        cd_genshizai: { text: "原材料编号" },
        nm_genshizai: { text: "原材料名" },
        dt_hiduke: { text: "日期" },
       // kbn_ukeharai: { text: "入出厂" },
        kbn_ukeharai: { text: "出入库" },
       // su_nyusyukko: { text: "入出厂数" },
        su_nyusyukko: { text: "出入库数" },
        //no_lot: { text: "批量NO．" },
        no_lot: { text: "批号" },
        cd_seihin: { text: "编号" },
        nm_seihin: { text: "品名" },
        nm_memo: { text: "备忘录" },
        nm_shokuba: { text: "车间" },
        nm_line: { text: "生产线名" },
        //受払区分
        nonyuYotei: { text: "入库预定" },
        nonyuJisseki: { text: "入库实际" },
        shiyoYotei: { text: "使用预定" },
        shiyoJisseki: { text: "使用实际" },
        chosei: { text: "调整数" },
        seizoYotei: { text: "生产预定" },
        seizoJisseki: { text: "生产实际" },
        // その他：文言
        startDate: { text: "开始日" },
        endDate: { text: "结束日" },
         // 開始日～終了日の最大期間日数
        maxPeriod: { text: "184" },
           
        // 幅調整
        nm_kbn_hin_width: { number: 70 },
        last_date_width: { number: 110 },
        each_lang_width: { number: 90 },
        kbn_ukeharai_width: { number: 70 },
        flg_mishiyobun_width: { number: 195 },
        ari_nomi_width: { number: 195 },
        flg_today_jisseki_width: { number: 195 }
        // ここまで

    });

    App.ui.pagedata.validation("zh", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        // 検索条件
        dt_hiduke_from: {
            rules: {
                required: "开始日期",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
                
            },

            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247 
            }
        },
        dt_hiduke_to: {
            rules: {
                required: "结束日期",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 1, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        kbn_hin: {
            rules: {
                required: "品区分"
            },
            messages: {
                required: MS0042
            }
        },
        cd_genshizai: {
            rules: {
                maxbytelength: 14,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        }
        // TODO: ここまで
    });

    // 権限設定
    App.ui.pagedata.operation("zh", {
        search: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });

})();
