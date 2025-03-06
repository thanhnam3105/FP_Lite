
(function () {
    // 定数設定
    var lang = App.ui.pagedata.lang("ja", {
        // 画面タイトル
        _pageTitle: { text: "納入予定リスト作成" },
        // 項目名・検索条件
        con_dt_nonyu: { text: "日付" },
        con_kbn_hin: { text: "品区分" },
        con_cd_bunrui: { text: "品分類" },
        con_kbn_hokan: { text: "品位状態" },
        con_flg_torihiki: { text: "取引先" },
        all_torihiki: { text: "全取引" },
        select_torihiki: { text: "取引先選択"},
        con_head_nm_torihiki: { text: "取引先１(物流)" },
        con_cd_torihiki: { text: "取引先コード" },
        con_nm_torihiki: { text: "取引先名" },
        // 項目名・画面項目見出し
        set_no_nonyusho: { text: "納入書番号連続設定" },
        // 項目名・明細
        flg_kakutei: { text: "確定" },
        no_nonyusho: { text: "納入書番号" },
        nm_bunrui: { text: "品分類" },
        cd_hinmei: { text: "原資材コード" },
        nm_genshizai: { text: "原資材名" },
        nm_nisugata_hyoji: { text: "荷姿" },
        nm_tani: { text: "納入単位" },
        nm_tani_hasu: { text: "端数単位" },
        su_nonyu_yo: { text: "納入予定" },
        su_nonyu_yo_hasu: { text: "予定端数" },
        su_nonyu_ji: { text: "納入実績" },
        su_nonyu_hasu: { text: "実績端数" },
        tan_nonyu: { text: "納入単価" },
        kin_kingaku: { text: "金額" },
        nm_zei: { text: "税区分" },
        nm_torihiki: { text: "取引先１(物流)" },
        nm_torihiki2: { text: "取引先２(商流)" },
        dt_nonyu: { text: "納入実績日" },
        kbn_nyuko: { text: "入庫区分" },
        dt_nonyu_yotei: { text: "納入予定日" },
        // 項目名・隠し項目
        no_nonyu: { text: "納入番号" },
        cd_tani_nonyu: { text: "納入単位コード" },
        cd_tani_nonyu_hasu: { text: "納入単位コード(端数)" },
        save_su_nonyu_ji: { text: "検索時納入実績" },
        ma_tan_nonyu: { text: "原資材購入先マスタ納入単価" },
        ma_tan_nonyu_new: { text: "原資材購入先マスタ新納入単価" },
        ma_dt_tanka_new: { text: "原資材購入先マスタ新単価切替日" },
        su_iri: { text: "入数" },
        kbn_zei: { text: "税区分" },
        cd_torihiki: { text: "取引先コード" },
        cd_torihiki2: { text: "取引先コード２" },
        // ラジオボタン：検索条件/取引先・全取引先
        conFlgTorihiki_zen: { text: "0" },
        nmFlgTorihiki_zen: { text: "全取引先" },
        // ラジオボタン：検索条件/取引先・取引先選択
        conFlgTorihiki_sentaku: { text: "1" },
        nmFlgTorihiki_sentaku: { text: "取引先選択" },

        reqYoteiDate: { text: "納入予定日" },
        reqYoteiSu: { text: "納入予定" },
        reqYoteiData: { text: "納入予定または納入実績" },
        reqJisseki: { text: "納入実績または端数、金額、納入実績日" },
       
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
    App.ui.pagedata.validation("ja", {
        // 検索条件/日付
        con_dt_nonyu: {
            rules: {
                required: "日付",
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
                custom: "取引先コード"
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
                required: "原資材コード",
                maxbytelength: 14,
                alphanum: true
            },
            params: {
                custom: "原資材コード"
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
        // 明細/実績端数
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
                required: "取引先１(物流)"
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
    App.ui.pagedata.operation("ja", {
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
