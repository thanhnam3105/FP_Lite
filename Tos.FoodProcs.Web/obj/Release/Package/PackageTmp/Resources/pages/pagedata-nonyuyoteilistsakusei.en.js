
(function () {
    // 定数設定
    var lang = App.ui.pagedata.lang("en", {
        // 画面タイトル
        _pageTitle: { text: "Purchase List" },
        // 項目名・検索条件
        con_dt_nonyu: { text: "Date" },
        con_kbn_hin: { text: "Item type" },
        con_cd_bunrui: { text: "Item group" },
        con_kbn_hokan: { text: "Condition of quality" },
        all_torihiki: { text: "All vendors" },
        select_torihiki: { text: "Select vendor" },
        con_flg_torihiki: { text: "Vendor" },
        con_head_nm_torihiki: { text: "Vendor1(Logistics)" },
        con_cd_torihiki: { text: "Vendor code" },
        con_nm_torihiki: { text: "Vendor name" },
        // 項目名・画面項目見出し
        //set_no_nonyusho: { text: "Delivery paper quantity sequence setting" },
        set_no_nonyusho: { text: "Delivery paper continuous setting" },
        // 項目名・明細
        flg_kakutei: { text: "Confirm" },
        no_nonyusho: { text: "Delivery paper No." },
        nm_bunrui: { text: "Item group" },
        cd_hinmei: { text: "Material code" },
        nm_genshizai: { text: "Material name" },
        nm_nisugata_hyoji: { text: "Packing<br>style" },
        nm_tani: { text: "Delivery<br>unit" },
        nm_tani_hasu: { text: "Partial<br>unit" },
        su_nonyu_yo: { text: "Plan<br>Regular" },
        su_nonyu_yo_hasu: { text: "Plan<br>Partial" },
        su_nonyu_ji: { text: "Actual<br>delivery" },
        su_nonyu_hasu: { text: "Actual<br>partial" },
        tan_nonyu: { text: "Delivery unit<br>price" },
        kin_kingaku: { text: "Amount" },
        nm_zei: { text: "Tax<br>type" },
        nm_torihiki: { text: "Vendor1<br>(Logistics)" },
        nm_torihiki2: { text: "Vendor2<br>(Commercial distribution)" },
        dt_nonyu: { text: "Actual<br>delivery date" },
        kbn_nyuko: { text: "Warehousing<br>division" },
        dt_nonyu_yotei: { text: "Delivery<br>plan date" },
        // 項目名・隠し項目
        no_nonyu: { text: "Delivery number" },
        cd_tani_nonyu: { text: "Delivery unit code" },
        cd_tani_nonyu_hasu: { text: "Partial unit code" },
        save_su_nonyu_ji: { text: "Actual delivery at search time" },
        ma_tan_nonyu: { text: "Raw & packing materials vendor master new price of delivery" },
        ma_tan_nonyu_new: { text: "Raw & packing materials vendor master new price of delivery" },
        ma_dt_tanka_new: { text: "Raw & packing materials vendor master change date for new unit price" },
        su_iri: { text: "Contained number" },
        kbn_zei: { text: "Tax type" },
        cd_torihiki: { text: "Vendor code" },
        cd_torihiki2: { text: "Vendor code2" },
        // ラジオボタン：検索条件/取引先・全取引先
        conFlgTorihiki_zen: { text: "0" },
        nmFlgTorihiki_zen: { text: "All vendors" },
        // ラジオボタン：検索条件/取引先・取引先選択
        conFlgTorihiki_sentaku: { text: "1" },
        nmFlgTorihiki_sentaku: { text: "Select vendor" },

        reqYoteiDate: { text: "Delivery plan date" },
        reqYoteiSu: { text: "Delivery plan" },
        reqYoteiData: { text: "Delivery plan or Actual delivery" },
        reqJisseki: { text: "Actual delivery or Partial、Amount、Actual delivery date" },
       
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
        flg_kakutei_width: { number: 95 },
        no_nonyu_width: { number: 120 },
        no_nonyusho_width: { number: 140 },
        nm_bunrui_width: { number: 130 },
        cd_hinmei_width: { number: 155 },
        nm_genshizai_width: { number: 155 },
        nm_nisugata_hyoji_width: { number: 77 },
        nm_tani_width: { number: 78 },
        su_nonyu_yo_width: { number: 87 },
        su_nonyu_ji_width: { number: 87 },
        su_nonyu_hasu_width: { number: 65 },
        tan_nonyu_width: { number: 82 },
        kin_kingaku_width: { number: 85 },
        nm_zei_width: { number: 80 },
        nm_torihiki_width: { number: 155 },
        nm_torihiki2_width: { number: 185 },
        dt_nonyu_width: { number: 115 },
        kbn_nyuko_width: { number: 120 },
        each_lang_width: { number: 130 }
    });

    // バリデーション設定
    App.ui.pagedata.validation("en", {
        // 検索条件/日付
        con_dt_nonyu: {
            rules: {
                required: "Date",
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
                custom: "Vendor code"
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
                required: "Raw materials & packing materials code",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "Raw materials & packing materials code"
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        // 明細/納入予定数
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
        // 明細/実績端数
        su_nonyu_ji: {
            rules: {
                //required: "Actual delivery",
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
                //required: "Amount",
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
                required: "Vendor1(Logistics)"
            },
            messages: {
                required: MS0042
            }
        },
        // 明細/納入実績日
        dt_nonyu: {
            rules: {
                //required: "Actual delivery date",
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
    App.ui.pagedata.operation("en", {
        // ボタン：行追加
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
