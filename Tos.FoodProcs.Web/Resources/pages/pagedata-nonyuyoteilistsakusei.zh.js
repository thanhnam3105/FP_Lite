
(function () {
    // 定数設定
    var lang = App.ui.pagedata.lang("zh", {
        // 画面タイトル
        _pageTitle: { text: "入库预定列表作成" },
        // 項目名・検索条件
        con_dt_nonyu: { text: "日期" },
        //con_kbn_hin: { text: "品区分" },
        con_kbn_hin: { text: "商品区分" },
        //con_cd_bunrui: { text: "品分类" },
        con_cd_bunrui: { text: "商品分类" },
        con_kbn_hokan: { text: "成份状态" },
        con_flg_torihiki: { text: "厂商" },
        all_torihiki: { text: "全部厂商" },
        select_torihiki: { text: "厂商选择" },
        con_head_nm_torihiki: { text: "厂商１(物流)" },
        con_cd_torihiki: { text: "厂商编号" },
        con_nm_torihiki: { text: "厂商名" },
        // 項目名・画面項目見出し
        set_no_nonyusho: { text: "入库单号连续设定" },
        // 項目名・明細
        flg_kakutei: { text: "确定" },
        no_nonyusho: { text: "入库单号" },
        //nm_bunrui: { text: "品分类" },
        nm_bunrui: { text: "商品分类" },
        cd_hinmei: { text: "原材料编号" },
        nm_genshizai: { text: "原材料名" },
        nm_nisugata_hyoji: { text: "包装" },
        nm_tani: { text: "入库単位" },
        //nm_tani_hasu: { text: "零数単位" },
        nm_tani_hasu: { text: "零头数単位" },
        su_nonyu_yo: { text: "入库预定" },
       // su_nonyu_yo_hasu: { text: "预定零数" },
        su_nonyu_yo_hasu: { text: "预定零头数" },
        su_nonyu_ji: { text: "入库实际" },
        //su_nonyu_hasu: { text: "零数" },
        su_nonyu_hasu: { text: "零头数" },
        tan_nonyu: { text: "入库单价" },
        kin_kingaku: { text: "金额" },
        nm_zei: { text: "税区分" },
        nm_torihiki: { text: "厂商１(物流)" },
        nm_torihiki2: { text: "厂商２(商人)" },
        dt_nonyu: { text: "入库实际日" },
        kbn_nyuko: { text: "入库区分" },
        dt_nonyu_yotei: { text: "入库预定日" },
        // 項目名・隠し項目
        no_nonyu: { text: "入库编号" },
        cd_tani_nonyu: { text: "入库单位编号" },
        //cd_tani_nonyu_hasu: { text: "入库单位编号(零数)" },
        cd_tani_nonyu_hasu: { text: "入库单位编号(零头数)" },
        save_su_nonyu_ji: { text: "查找时入库实际" },
        ma_tan_nonyu: { text: "原材料购买商主表入库单价" },
        ma_tan_nonyu_new: { text: "原材料购买商主表新入库单价" },
        ma_dt_tanka_new: { text: "原材料购买商主表新单价切换日" },
        su_iri: { text: "装箱数" },
        kbn_zei: { text: "税区分" },
        cd_torihiki: { text: "厂商编号" },
        cd_torihiki2: { text: "厂商编号２" },
        // ラジオボタン：検索条件/取引先・全取引先
        conFlgTorihiki_zen: { text: "0" },
        nmFlgTorihiki_zen: { text: "全部厂商" },
        // ラジオボタン：検索条件/取引先・取引先選択
        conFlgTorihiki_sentaku: { text: "1" },
        nmFlgTorihiki_sentaku: { text: "厂商选择" },

        reqYoteiDate: { text: "入库预定日" },
        reqYoteiSu: { text: "入库预定" },
        reqYoteiData: { text: "入库预定或入库实际" },
        //reqJisseki: { text: "入库实际或零数,金额,入库实际日" },
        reqJisseki: { text: "入库实际或零头数,金额,入库实际日" },

        // 画面メッセージＩＤ
        limitOver: { text: MS0011 },
        notFound: { text: MS0037 },
        required: { text: MS0042 },
        changeCriteria: { text: MS0048 },
        saveConfirm: { text: MS0064 },
        searchConfirm: { text: MS0065 },
        unloadWithoutSave: { text: MS0066 },
        combinationduplicate: { text: MS0201 },
        noRecords: { text: MS0442 },
        noChange: { text: MS0444 },
        gridChange: { text: MS0560 },
        konyuNotFound: { text: MS0595 },
        niukeJissekiExists: { text: MS0750 },
        suNonyuYoteiZero: { text: MS0809 },
        canNotUpdateDataOld: { text: MS0823 },
        specifiedParamDoesNotExist: { text: MS0049 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        flg_kakutei_width: { number: 55 },
        no_nonyu_width: { number: 120 },
        no_nonyusho_width: { number: 95 },
        nm_bunrui_width: { number: 130 },
        cd_hinmei_width: { number: 112 },
        nm_genshizai_width: { number: 155 },
        nm_nisugata_hyoji_width: { number: 77 },
        nm_tani_width: { number: 78 },
        su_nonyu_yo_width: { number: 87 },
        su_nonyu_ji_width: { number: 87 },
        su_nonyu_hasu_width: { number: 57 },
        tan_nonyu_width: { number: 82 },
        kin_kingaku_width: { number: 75 },
        nm_zei_width: { number: 65 },
        nm_torihiki_width: { number: 155 },
        nm_torihiki2_width: { number: 155 },
        dt_nonyu_width: { number: 95 },
        kbn_nyuko_width: { number: 85 },
        each_lang_width: { number: 90 }
    });

    // バリデーション設定
    App.ui.pagedata.validation("zh", {
        // 検索条件/日付
        con_dt_nonyu: {
            rules: {
                required: "日期",
                datestring: true,
                lessdate: new Date(1975, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        // 検索条件/取引先コード
        con_cd_torihiki: {
            rules: {
                alphanum: true
            },
            params: {
                custom: "厂商编号"
            },
            messages: {
                alphanum: MS0439,
                custom: MS0049
            }
        },
        // 連続設定用納入書番号
        copy_no_nonyusho: {
            rules: {
                alphanum: true
            },
            messages: {
                alphanum: MS0439,
                custom: MS0196
            }
        },
        // 明細/納入書番号
        no_nonyusho: {
            rules: {
                maxbytelength: 20,
                alphanum: true
            },
            messages: {
                maxbytelength: MS0012,
                alphanum: MS0439
            }
        },
        // 明細/原資材コード
        cd_hinmei: {
            rules: {
                required: "原材料编号",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "原材料编号"
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        // 明細/納入予定
        su_nonyu_yo: {
            rules: {
                //required: "納入予定",
                number: true,
                range: [0, 999999]
            },
            messages: {
                //required: MS0042,
                number: MS0441,
                range: MS0009
            }
        },
        // 明細/予定端数
        su_nonyu_yo_hasu: {
            rules: {
                //number: true,
                //range: [0, 999]
                number: true
            },
            messages: {
                number: MS0441,
               //range: MS0009,
                custom: MS0205
            }
        },
        // 明細/納入実績
        su_nonyu_ji: {
            rules: {
                //required: "納入実績",
                number: true,
                range: [0, 999999]
            },
            messages: {
                //required: MS0042,
                number: MS0441,
                range: MS0009
            }
        },
        // 明細/端数
        su_nonyu_hasu: {
            rules: {
                //number: true,
                range: [0, 999]
            },
            messages: {
                //number: MS0441,
                range: MS0009,
                custom: MS0205
            }
        },
        // 明細/納入単価
        tan_nonyu: {
            rules: {
                number: true,
                range: [0, 99999999.999]
            },
            messages: {
                number: MS0441,
                range: MS0009
            }
        },
        // 明細/金額
        kin_kingaku: {
            rules: {
                //required: "金額",
                number: true,
                range: [0, 99999999]
            },
            messages: {
                //required: MS0042,
                number: MS0441,
                range: MS0009
            }
        },
        // 明細/取引先１(物流)
        nm_torihiki: {
            rules: {
                required: "厂商１(物流)"
            },
            messages: {
                required: MS0042
            }
        },
        // 明細/納入実績日
        dt_nonyu: {
            rules: {
                //required: "納入実績日",
                datestring: true,
                lessdate: new Date(1950, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                //required: MS0042,
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
            }
        },
        // 明細/納入予定日
        dt_nonyu_yotei: {
            rules: {
                datestring: true,
                lessdate: new Date(1950, 1 - 1, 1 - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                datestring: MS0247,
                lessdate: MS0247,
                greaterdate: MS0247
                //custom: MS0738
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("zh", {
        search: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        colChangeButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：行追加
        lineAddButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：行削除
        lineDeleteButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：全チェック/解除
        checkButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：原資材一覧
        genshizaiButton: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：取引先一覧
        torihikiButton: {
            Editor: { visible: false },
            Viewer: { visible: false }, Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // チェックボックス：納入書番号連続設定
        setNoNonyusho: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        excel: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：保存
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });
})();
