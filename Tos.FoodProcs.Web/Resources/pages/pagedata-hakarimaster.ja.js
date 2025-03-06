(function () {
    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "秤マスタ一覧" },
        flg_mishiyo_kensaku: { text: "未使用表示" },
        cd_hakari: { text: "秤コード" },
        nm_hakari: { text: "型式" },
        nm_tani: { text: "単位" },
        cd_tani: { text: "単位コード" },
        joken_tushin: { text: "通信条件" },
        kbn_baurate: { text: "ボーレート" },
        kbn_parity: { text: "パリティ" },
        kbn_databit: { text: "データ長" },
        kbn_stopbit: { text: "ストップビット" },
        kbn_handshake: { text: "ハンドシェイク" },
        nm_antei: { text: "安定" },
        nm_fuantei: { text: "不安定" },
        su_keta: { text: "桁" },
        no_ichi_juryo: { text: "重量" },
        su_ichi_fugo: { text: "符号" },
        cd_fundo: { text: "分銅コード" },
        wt_fundo: { text: "標準分銅" },
        disp_fugo: { text: "符号出力" },
        flg_fugo: { text: "符号未出力" },
        flg_mishiyo: { text: "未使用" },
        flg_hakari_check: { text: "秤点検" },
        flg_mishiyo_shosai: { text: "使用しない場合" },
        dt_create: { text: "登録日" },
        cd_create: { text: "登録者" },
        dt_update: { text: "更新日" },
        cd_update: { text: "更新者" },
        no_com: { text: "COMポート数" },
        ts: { text: "タイムスタンプ" },

        dispFugoMsg: { text: "しない" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        noRecords: { text: MS0442 },
        noSelect: { text: MS0443 },
        noChange: { text: MS0444 },
        saveConfirm: { text: MS0064 },
        saveComplete: { text: MS0036 },
        deleteConfirm: { text: MS0068 },
        deleteComplete: { text: MS0039 },
        unloadWithoutSave: { text: MS0066 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        cd_hakari_width: { number: 80 },
        nm_hakari_width: { number: 200 },
        nm_tani_width: { number: 80 },
        nm_kbn_baurate_width: { number: 100 },
        nm_kbn_parity_width: { number: 100 },
        nm_kbn_databit_width: { number: 100 },
        nm_kbn_stopbit_width: { number: 120 },
        nm_kbn_handshake_width: { number: 120 },
        nm_antei_width: { number: 60 },
        nm_fuantei_width: { number: 65 },
        no_ichi_juryo_width: { number: 50 },
        su_keta_width: { number: 50 },
        su_ichi_fugo_width: { number: 50 },
        wt_fundo_width: { number: 120 },
        flg_fugo_width: { number: 90 },
        flg_mishiyo_width: { number: 70 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        cd_hakari: {
            rules: {
                required: "秤コード",
                alphanum: true,
                maxlength: 10
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0021
            }
        },
        nm_antei: {
            rules: {
                required: "安定名",
                alphanum: true,
                maxlength: 6
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0021
            }
        },
        nm_hakari: {
            rules: {
                required: "型式",
                maxbytelength: 50
            },
            messages: {
                required: MS0042,
                maxbytelength: MS0012
            }
        },
        nm_fuantei: {
            rules: {
                required: "不安定名",
                alphanum: true,
                maxlength: 6
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                maxlength: MS0021
            }
        },
        cd_tani: {
            rules: {
                required: "単位"
            },
            messages: {
                required: MS0042
            }
        },
        no_ichi_juryo: {
            rules: {
                required: "重量",
                number: true,
                pointlength: [4, 0, true]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        kbn_baurate: {
            rules: {
                required: "ボーレート"
            },
            messages: {
                required: MS0042
            }
        },
        su_keta: {
            rules: {
                required: "桁",
                number: true,
                pointlength: [4, 0, true]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        kbn_parity: {
            rules: {
                required: "パリティ"
            },
            messages: {
                required: MS0042
            }
        },
        su_ichi_fugo: {
            rules: {
                required: "符号",
                number: true,
                pointlength: [4, 0, true]
            },
            messages: {
                required: MS0042,
                number: MS0441,
                pointlength: MS0440
            }
        },
        kbn_databit: {
            rules: {
                required: "データ長"
            },
            messages: {
                required: MS0042
            }
        },
        cd_fundo: {
            rules: {
                required: "標準分銅"
            },
            messages: {
                required: MS0042
            }
        },
        kbn_stopbit: {
            rules: {
                required: "ストップビット"
            },
            messages: {
                required: MS0042
            }
        },
        flg_fugo: {
            rules: {
                required: "符号出力"
            },
            messages: {
                required: MS0042
            }
        },
        kbn_handshake: {
            rules: {
                required: "ハンドシェイク"
            },
            messages: {
                required: MS0042
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        add: {
            Viewer: { visible: false }
        },
        save: {
            Viewer: { visible: false }
        },
        del: {
            Viewer: { visible: false }
        }
        // TODO: ここまで
    });
})();