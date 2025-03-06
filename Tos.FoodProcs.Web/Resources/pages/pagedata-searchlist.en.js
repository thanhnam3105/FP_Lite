(function () {
    var lang = App.ui.pagedata.lang("en", {
        // TODO: ��ʂ̎d�l�ɉ����Ĉȉ��̉�ʍ��ڂ̃e�L�X�g��ύX���Ă��������B
        _pageTitle: { text: "ID0003:Master List Formulation" },
        combDetail: { text: "compounded details" },
        categoryCode: { text: "category code" },
        categoryName: { text: "category name" },
        articleDivisionCD: { text: "article type code" },
        articleDivisionName: { text: "article type name" },
        combinationCD: { text: "compounded code" },
        combinationName: { text: "compounded name" },
        combinationShortName: { text: "short compounded name" },
        combinationRomaName: { text: "romanization compounded name" },
        yield: { text: "hold" },
        baseWeight: { text: "basis weight" },
        vwDivision: { text: "v/w type" },
        specificGravity: { text: "specific gravity" },
        facilitiesCD: { text: "facilities code" },
        facilitiesName: { text: "facilities name" },
        maxWeight: { text: "maximum weight charged" },
        lineCode: { text: "line code" },
        lineName: { text: "line name" },
        priority: { text: "priority" },
        combinationID: { text: "sequence number" },
        other: { text: "other plant" },
        recipe: { text: "recipe" }
        // TODO: �����܂�
    });

    App.ui.pagedata.validation("en", {
        // TODO: ��ʂ̎d�l�ɉ����Ĉȉ��̃o���f�[�V�������[���ƃo���f�[�V�������b�Z�[�W��ύX���Ă��������B
        combinationCD: {
            rules: { required: true },
            messages: { required: "compounded code is required." }
        },
        combinationName: {
            rules: { required: true },
            messages: { required: "compounded name is required." }
        },
        yield: { 
            rules: { digits: true },
            messages: { digits: "hold is remaining please enter a number." }
        },
        categoryName: {
            rules: { required: true },
            messages: { required: "category name is required." }
        },
        articleDivisionName: {
            rules: { required: true },
            messages: { required: "article type name is required." }
        },
        facilitiesName: {
            rules: { required: true },
            messages: { required: "facilities name is required." }
        }
        // TODO: �����܂�
    });

    //��1�����̃��P�[�������ł̐ݒ���\
    App.ui.pagedata.operation("en", {
        // TODO: ��ʂ̎d�l�ɉ����Ĉȉ��̉�ʐ��䃋�[����ύX���Ă��������B
        // TODO: �����܂�
    });
})();
