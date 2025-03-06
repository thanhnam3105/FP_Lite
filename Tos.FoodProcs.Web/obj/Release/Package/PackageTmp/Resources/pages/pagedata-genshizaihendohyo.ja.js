(function () {
    //// ページデータ -- Start

    var lang = App.ui.pagedata.lang("ja", {
        // TODO: 画面の仕様に応じて以下の画面項目のテキストを変更してください。
        _pageTitle: { text: "原資材変動表" },
        dt_keikaku_nonyu: { text: "納入計画自動作成最終日" },
        // 明細
        cd_hinmei: { text: "品名コード" },
        dt_hizuke: { text: "月日" },
        dt_yobi: { text: "曜日" },
        flg_kyujitsu: { text: "休日" },
        flg_shukujitsu: { text: "祝日" },
        su_nonyu_yotei: { text: "納入予定" },
        su_nonyu_jisseki: { text: "納入実績" },
        su_shiyo_yotei: { text: "使用予定" },
        su_shiyo_jisseki: { text: "使用実績" },
        su_seizo_yotei: { text: "製造予定" },
        su_seizo_jisseki: { text: "製造実績" },
        su_chosei: { text: "調整数" },
        su_keisanzaiko: { text: "計算在庫数" },
        su_jitsuzaiko: { text: "実在庫数" },
        su_kurikoshi_zan: { text: "繰越在庫" },
        ts: { text: "タイムスタンプ" },
        cd_toroku: { text: "登録者" },
        dt_toroku: { text: "登録日時" },
        su_ko: { text: "個数" },
        su_iri: { text: "入数" },
        cd_tani: { text: "納入単位" },
        // 検索条件
        hizuke: { text: "日付" },
        hinCode: { text: "品名コード" },
        hinName: { text: "品名" },
        nisugata: { text: "荷姿" },
        hacchuLotSize: { text: "発注ロットサイズ" },
        nonyuLeadTime: { text: "納入リードタイム" },
        saiteiZaiko: { text: "最低在庫" },
        biko: { text: "備考" },
        shiyoTani: { text: "使用単位" },
        konyusakiCode: { text: "購入先コード" },
        konyusakiName: { text: "購入先名" },
        // その他：画面項目
        kurikoshiZaiko: { text: "繰越在庫" },
        kurikoshiZan: { text: "繰越残" },
        nonyuYoteiGokei: { text: "納入予定合計" },
        nonyuJissekiGokei: { text: "納入実績合計" },
        seizoYoteiGokei: { text: "製造予定合計" },
        seizoJissekiGokei: { text: "製造実績合計" },
        shiyoYoteiGokei: { text: "使用予定合計" },
        shiyoJissekiGokei: { text: "使用実績合計" },
        choseiGokei: { text: "調整数合計" },
        shiyoIchiran: { text: "使用一覧" },
        between: { text: "　～　" },
        total: { text: "合計" },
        // その他：文言
        startDate: { text: "開始日" },
        endDate: { text: "終了日" },
        choseiData: { text: "調整データ" },
        zaikoData: { text: "在庫データ" },
        initChoseiKey: { text: "理由、原価センター、倉庫" },
        initZaikoKey: { text: "倉庫" },
        // 開始日～終了日の最大期間日数
        maxPeriod: { text: "186" },
        // TODO: ここまで
        // TODO: 画面の仕様に応じて以下の画面メッセージを変更してください。
        initErr: { text: MS0736 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        dt_hizuke_width: { number: 90 },
        dt_yobi_width: { number: 40 },
        su_nonyu_yotei_width: { number: 125 },
        su_nonyu_jisseki_width: { number: 125 },
        su_shiyo_yotei_width: { number: 125 },
        su_shiyo_jisseki_width: { number: 125 },
        su_chosei_width: { number: 125 },
        su_keisanzaiko_width: { number: 125 },
        su_jitsuzaiko_width: { number: 125 },
        total_width: { number: 130 }
        // TODO: ここまで
    });

    App.ui.pagedata.validation("ja", {
        // TODO: 画面の仕様に応じて以下のバリデーションルールとバリデーションメッセージを変更してください。
        su_nonyu_yotei: {
            rules: {
                number: MS0441,
//                pointlength: [6, 2, true],
//                range: [0, 999999.99]
                pointlength: [6, 3, true],
                range: [0, 999999.999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        su_chosei: {
            rules: {
                number: MS0441,
//                pointlength: [6, 6, true],
//                range: [-999999.999999, 999999.999999]
                pointlength: [6, 3, true],
                range: [-999999.999, 999999.999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        su_jitsuzaiko: {
            rules: {
                number: MS0441,
//                pointlength: [8, 6, true],
//                range: [0, 99999999.999999]
                pointlength: [8, 3, true],
                range: [0, 99999999.999]
            },
            messages: {
                number: MS0441,
                pointlength: MS0440,
                range: MS0450
            }
        },
        // 検索条件
        hizuke: {
            rules: {
                required: "開始日",
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
        hizuke_to: {
            rules: {
                required: "終了日",
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
        hinCode: {
            rules: {
                required: "品名コード",
                alphanum: true,
                custom: true
            },
            params: {
                custom: "品名コード"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                custom: MS0037
            }
        }
        // TODO: ここまで
    });

    //第1引数のロケール無しでの設定も可能
    App.ui.pagedata.operation("ja", {
        // TODO: 画面の仕様に応じて以下の画面制御ルールを変更してください。
        save: {
            Editor: { visible: false },
            Viewer: { visible: false },
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
        // TODO: ここまで
    });

    //// ページデータ -- End
})();
