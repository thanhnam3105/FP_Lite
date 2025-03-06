(function () {

    App.ui.pagedata.lang("en", {
        masterKubunId: { data: [{ id: "1", name: "Material master" }, { id: "2", name: "Formula master"}] }
        , jotaiKubunId: { data: [{ id: "1", name: "Solid" }, { id: "2", name: "Liquid" }, { id: "3", name: "Progressing product" }, { id: "9", name: "Other"}] }
        , hokanKubunId: { data: [{ id: "1", name: "Normal temperature" }, { id: "2", name: "Cold storage" }, { id: "3", name: "Freezer storage"}] }
        , yobiId: { data: [{ id: "0", name: "Sunday", shortName: "Sun" }, { id: "1", name: "Monday", shortName: "Mon" }, { id: "2", name: "Tuesday", shortName: "Tue" }, { id: "3", name: "Wednesday", shortName: "Wed" }, { id: "4", name: "Thursday", shortName: "Thu" }, { id: "5", name: "Friday", shortName: "Fri" }, { id: "6", name: "Saturday", shortName: "Sat"}] }
        , yobiHidukeId: { data: [{ id: "0", name: "{0}(SUN)" }, { id: "1", name: "{0}(MON)" }, { id: "2", name: "{0}(TUE)" }, { id: "3", name: "{0}(WED)" }, { id: "4", name: "{0}(THU)" }, { id: "5", name: "{0}(FRI)" }, { id: "6", name: "{0}(SAT)"}] }
        , kuraireId: { data: [{ id: "1", name: "Warehousing immediately" }, { id: "2", name: "Unwrapped" }, { id: "3", name: "No warehousing"}] }
        , nonyushoId: { data: [{ id: "0", name: "" }, { id: 1, name: "Delivery amount" }, { id: 2, name: "usage amount"}] }
        , kanzanKubunId: { data: [{ id: "4", name: "Ｋｇ" }, { id: "11", name: "Ｌ"}] }
        , gassanKubunId: { data: [{ id: "0", name: "No" }, { id: "1", name: "Total"}] }
        //, kengenKubunId: { data: [{ id: "Admin", name: "Administrator" }, { id: "Editor", name: "Editor" }, { id: "Operator", name: "Operator" }, { id: "Viewer", name: "Viewer"}] }
        , kengenKubunId: { data: [{ id: "Admin", name: "Administrator" }, { id: "Manufacture", name: "Manufacturer" }, { id: "Purchase", name: "Purchaser" }, { id: "Quality", name: "Quality person" }, { id: "Warehouse", name: "Warehouse person"}] }
        , monthNameId: { data: [{ id: 0, name: "January", shortName: "Jan" }, { id: 1, name: "February", shortName: "Feb" }, { id: 2, name: "March", shortName: "Mar" }, { id: 3, name: "April", shortName: "Apr" }, { id: 4, name: "May", shortName: "May" }, { id: 5, name: "June", shortName: "Jun" }, { id: 6, name: "July", shortName: "Jul" }, { id: 7, name: "August", shortName: "Aug" }, { id: 8, name: "September", shortName: "Sep" }, { id: 9, name: "October", shortName: "Oct" }, { id: 10, name: "November", shortName: "Nov" }, { id: 11, name: "December", shortName: "Dec"}] }
        , tenkaiKubunId: { data: [{ id: 0, name: "No" }, { id: 1, name: "Yes"}] }
        , riyuBunruiKubunId: { data: [{ id: 1, name: "Reason of preparation" }, { id: 2, name: "Reason of holiday"}] }
        , dateFormatId: { data: [{ id: 0, number: 2 }, { id: 1, number: 2 }, { id: 2, number: 4}] }
        , nyukoKunbunId: { data: [{ id: 1, name: "Chargeable" }, { id: 7, name: "Free of charge"}] }
        , densoKunbunId: { data: [{ id: 1, name: "Create" }, { id: 2, name: "Update" }, { id: 3, name: "Delete"}] }
        // ■仕掛残計上機能OFF対応(機能ONは下のコメントアウトをオープンして下さい):リストボックスから削除
        , anbunKubunId: { data: [{ id: 1, name: "Productions" }, { id: 2, name: "Adjustment" }/*, { id: 3, name: "Process inventory"}*/] }
        , densoJotaiId: { data: [{ id: 0, name: "Not created" }, { id: 1, name: "Not transmitted" }, { id: 2, name: "Pending" }, { id: 3, name: "Transmitting now" }, { id: 4, name: "Transmitted"}] }
        , torokuJotaiId: { data: [{ id: 0, name: "Unregistered" }, { id: 1, name: "Pending" }, { id: 2, name: "Registered" }] }
        // 最終行はカンマ不要
        //---------------------------------------------------------
        //2019/07/23 trinh.bd Task #14029
        //------------------------START----------------------------
        , roleNewId: { data: [{ id: 0, name: "" }, { id: 1, name: "View only" }, { id: 2, name: "Update" }] }
        //-------------------------END-----------------------------
    });

})();