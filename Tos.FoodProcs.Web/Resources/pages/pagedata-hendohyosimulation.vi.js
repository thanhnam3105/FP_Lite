
(function () {
    // 定数設定
    var lang = App.ui.pagedata.lang("vi", {
        // 画面タイトル
        _pageTitle: { text: "Mô phỏng bảng biến động" },
        // 項目名・検索条件
        con_dt_hizuke: { text: "Ngày" },
        con_cd_hinmei: { text: "Mã sản phẩm" },
        con_nm_hinmei: { text: "Tên sản phẩm" },
        con_seizo_yotei: { text: "Dự định sản xuất" },
        con_str_case: { text: "C/S" },
        con_str_arrow: { text: "->" },
        con_after_change: { text: "Sau khi thay đổi" },
        // 原資材情報
        genshi_cd_konyu: { text: "Mã nhà cung cấp" },
        genshi_nm_konyu: { text: "Tên nhà cung cấp" },
        genshi_leadtime: { text: "Thời gian cung ứng" },
        genshi_zaiko_min: { text: "Tồn kho tối thiểu" },
        genshi_hachu_lot_size: { text: "Kích cỡ lô đặt hàng" },
        genshi_tani_shiyo: { text: "Đơn vị sử dụng" },
        // 明細項目名(シミュレーションスプレッド項目名)
        dt_hizuke: { text: "Ngày" },
        after_su_nonyu: { text: "SL mua hàng<br>(ĐV sử dụng)", tooltip: "Số lượng mua hàng (Đơn vị sử dụng)" },
        su_seizo: { text: "Lượng sản xuất" },
        before_wt_shiyo: { text: "SL sử dụng<br>trước thay đổi", tooltip: "Số lượng sử dụng trước thay đổi" },
        after_wt_shiyo: { text: "SL sử dụng<br>sau thay đổi", tooltip: "Số lượng sử dụng sau thay đổi" },
        before_wt_zaiko: { text: "Lượng tồn<br>trước thay đổi" },
        after_wt_zaiko: { text: "Lượng tồn<br>sau thay đổi" },
        su_zaiko: { text: "Lượng tồn thực tế" },
        // 明細原料項目名(原料スプレッド項目名)
        cd_genryo: { text: "Mã" },
        nm_genryo: { text: "Tên nguyên liệu" },
        genryo_wt_shiyo: { text: "Lượng sử dụng" },
        genryo_wt_zaiko: { text: "Lượng tồn kho" },
        // 明細資材項目名(資材スプレッド項目名)
        cd_shizai: { text: "Mã" },
        nm_shizai: { text: "Tên vật tư" },
        shizai_wt_shiyo: { text: "Lượng sử dụng" },
        shizai_wt_zaiko: { text: "Lượng tồn kho" },
        // 項目名・隠し項目
        dt_ymd: { text: "Năm tháng ngày" },
        flg_kyujitsu: { text: "Cờ báo ngày nghỉ" },
        save_before_su_nonyu: { text: "Lượng nhập trước khi thay đổi lúc tìm kiếm" },
        before_su_nonyu: { text: "Lượng nhập trước thay đổi" },
        flg_mishiyo: { text: "Không sử dụng" },
        genryo_bef_wt_shiyo: { text: "Lượng sử dụng trước thay đổi" },
        genryo_bef_wt_zaiko: { text: "Lượng tồn kho trước thay đổi" },
        su_shiyo: { text: "Lượng sử dụng" },
        ritsu_budomari: { text: "Tỉ lệ sử dụng" },
        shizai_bef_wt_shiyo: { text: "Lượng sử dụng trước thay đổi" },
        shizai_bef_wt_zaiko: { text: "Lượng tồn kho trước thay đổi" },
        dd_leadtime: { text: "Thời gian cung ứng" },
        su_zaiko_min: { text: "Tồn kho tối thiểu" },
        su_hachu_lot_size: { text: "Kích cỡ lô đặt hàng" },
        cd_tani_shiyo: { text: "Mã đơn vị sử dụng" },
        cd_tani_nonyu: { text: "Mã đơn vị nhập" },
        kbn_hin: { text: "Loại sản phẩm" },
        tan_nonyu: { text: "Đơn giá nhập" },
        kbn_zei: { text: "Phân loại thuế" },
        su_ko: { text: "Số lượng sản phẩm" },
        su_iri: { text: "Số lượng bên trong" },
        cd_tani:{ text: "Đơn vị nhập" },
        konyusaki: { text: "Nhà cung cấp" },
        konyusakiMaster: { text: 'màn hình "Master nhà cung cấp nguyên vật liệu"' },
        // EXCEL出力用文言
        str_genryo: { text: "Nguyên liệu" },
        str_shizai: { text: "Vật liệu" },
        //str_code: { text: "Code　　　 ：" },
        //str_name: { text: "Name　　　 ：" },
        str_code: { text: " Mã" },
        str_name: { text: " Tên" },
        su_seizo_excel: { text: "Số lượng sản xuất" },
        param_su_nonyu: { text: "Số lượng mua hàng" },
        // 画面メッセージＩＤ
        notFound: { text: MS0037 },
        changeCriteria: { text: MS0048 },
        saveConfirm: { text: MS0064 },
        keikakuConfirm: { text: MS0689 },
        searchConfirm: { text: MS0065 },
        unloadWithoutSave: { text: MS0066 },
        noRecords: { text: MS0442 },
        noChange: { text: MS0444 },
        gridChange: { text: MS0560 },
        line_shokuba_codeNotFound: { text: MS0122 },
        zaikoNotFound: { text: MS0615 },
        finishCalc: { text: MS0041 },
        // TODO: 画面の仕様に応じて以下の列幅を変更してください。
        dt_hizuke_width: { number: 50 },
        after_su_nonyu_width: { number: 104 },
        before_wt_shiyo_width: { number: 120 },
        after_wt_shiyo_width: { number: 120 },
        before_wt_zaiko_width: { number: 120 },
        after_wt_zaiko_width: { number: 120 },
        su_zaiko_width: { number: 130 },
        recipeHinmeiCode_width: { number: 112 },
        recipeHinmeiName_width: { number: 234 },
        genryo_wt_shiyo_width: { number: 130 },
        genryo_wt_zaiko_width: { number: 130 },
        cd_shizai_width: { number: 112 },
        nm_shizai_width: { number: 234 },
        shizai_wt_shiyo_width: { number: 130 },
        shizai_wt_zaiko_width: { number: 130 },
        each_lang_width: { number: 120 }
        // TODO: ここまで
    });

    // バリデーション設定
    App.ui.pagedata.validation("vi", {
        // 検索条件/日付
        con_dt_hizuke: {
            rules: {
                required: "Ngày",
                datestring: true,
                lessdate: new Date(new Date().getFullYear(), new Date().getMonth(), new Date().getDate() - 1),
                greaterdate: new Date(new Date().getFullYear() + 10, new Date().getMonth(), new Date().getDate() + 1)
            },
            messages: {
                required: MS0042,
                datestring: MS0247,
                lessdate: MS0127,
                greaterdate: MS0247
            }
        },
        // 検索条件/品名コード
        con_cd_hinmei: {
            rules: {
                required: "Mã sản phẩm",
                alphanum: true
            },
            params: {
                custom: "Mã sản phẩm"
            },
            messages: {
                required: MS0042,
                alphanum: MS0439,
                custom: MS0049
            }
        },
        // 検索条件/変更後
        con_after_change: {
            rules: {
                number: true,
                range: [0, 99999],
                digits: [5]
            },
            messages: {
                number: MS0441,
                range: MS0450,
                digits: MS0576
            }
        },
        // 明細/(変更後)納入数
        after_su_nonyu: {
            rules: {
                number: true,
                //range: [0, 999999.99]
                range: [0, 999999.999]
            },
            messages: {
                number: MS0441,
                range: MS0450
            }
        }
    });

    // 権限設定
    App.ui.pagedata.operation("vi", {
        // ボタン：計算
        calc: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：保存
        save: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：計画作成
        planmake: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：検索条件/製品一覧
        seihinIchiran: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        },
        // ボタン：EXCEL
        excel: {
            Manufacture: { visible: false },
            Quality: { visible: false },
            Warehouse: { visible: false }
        }
    });
})();