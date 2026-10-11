$(document).ready(function() {
    // Esc key listener to close inventory
    window.addEventListener('keyup', function(event) {
        if (event.key === "Escape") {
            closeInventory();
        }
    });

    // NUI Message listener
    window.addEventListener('message', function(event) {
        let data = event.data;

        if (data.action === "open") {
            openInventory(data);
        } else if (data.action === "close") {
            closeInventory();
        } else if (data.action === "updateItems") {
            updateInventory(data);
        }
    });

    function openInventory(data) {
        $("#inventory-container").fadeIn(200);

        // Update player info
        if(data.playerName) $("#player-name").text(data.playerName);
        if(data.weight !== undefined) updateWeight(data.weight, data.maxWeight);

        // Populate slots
        if(data.inventory) {
            renderInventory(data.inventory, "player-inventory-grid");
        }
    }

    function closeInventory() {
        $("#inventory-container").fadeOut(200);
        $.post('https://qb-inventory/close', JSON.stringify({}));
    }

    function updateWeight(current, max) {
        $("#player-weight").text((current / 1000).toFixed(1));
        $("#player-max-weight").text((max / 1000).toFixed(1));

        let percentage = (current / max) * 100;
        if(percentage > 100) percentage = 100;
        $("#player-weight-bar").css("width", percentage + "%");
    }

    // Export functions to window so other steps can access them if needed
    window.renderInventory = function(items, containerId) {
        let $container = $("#" + containerId);
        $container.empty();

        // Assuming max 50 slots for main inventory, pad with empty slots
        const maxSlots = 50;

        for (let i = 1; i <= maxSlots; i++) {
            let item = items.find(it => it && it.slot === i);
            let slotHtml = "";

            if (item) {
                // Determine category for filtering
                let itemClass = "item-slot";
                let type = item.type || "consumable";
                if(item.name.toLowerCase().includes("weapon")) type = "weapon";

                slotHtml = `
                    <div class="${itemClass} ui-draggable ui-droppable" data-slot="${i}" data-name="${item.name}" data-type="${type}">
                        <div class="item-count">${item.amount || 1}</div>
                        <div class="item-weight">${((item.weight * (item.amount || 1)) / 1000).toFixed(1)}</div>
                        <div class="item-image" style="background-image: url('images/${item.image || item.name + '.png'}');"></div>
                        <div class="item-name">${item.label || item.name}</div>
                    </div>
                `;
            } else {
                slotHtml = `
                    <div class="item-slot empty-slot ui-droppable" data-slot="${i}">
                    </div>
                `;
            }
            $container.append(slotHtml);
        }

        // Re-initialize drag and drop after rendering
        if (typeof window.initDragAndDrop === "function") {
            window.initDragAndDrop();
        }
    };

    window.initDragAndDrop = function() {
        $(".item-slot:not(.empty-slot)").draggable({
            helper: "clone",
            appendTo: "body",
            zIndex: 9999,
            revert: "invalid",
            start: function(event, ui) {
                $(this).css("opacity", "0.5");
            },
            stop: function(event, ui) {
                $(this).css("opacity", "1");
            }
        });

        $(".item-slot").droppable({
            accept: ".item-slot",
            hoverClass: "ui-state-hover",
            drop: function(event, ui) {
                let fromSlot = ui.draggable.data("slot");
                let toSlot = $(this).data("slot");
                let fromInventory = ui.draggable.closest('.inventory-grid').attr('id');
                let toInventory = $(this).closest('.inventory-grid').attr('id');

                // Prevent dropping on self
                if(fromSlot === toSlot && fromInventory === toInventory) return;

                $.post('https://qb-inventory/moveItem', JSON.stringify({
                    fromSlot: fromSlot,
                    toSlot: toSlot,
                    fromInv: fromInventory,
                    toInv: toInventory
                }));
            }
        });

        $(".equip-slot").droppable({
            accept: ".item-slot",
            hoverClass: "ui-state-hover",
            drop: function(event, ui) {
                let fromSlot = ui.draggable.data("slot");
                let equipType = $(this).data("type");

                $.post('https://qb-inventory/equipItem', JSON.stringify({
                    fromSlot: fromSlot,
                    type: equipType
                }));
            }
        });
    };

    function updateInventory(data) {
        if(data.inventory) {
            window.renderInventory(data.inventory, "player-inventory-grid");
        }
        if(data.otherInventory) {
            window.renderInventory(data.otherInventory, "other-inventory-grid");
        }
        if(data.weight !== undefined) {
            updateWeight(data.weight, data.maxWeight);
        }
    }

    // --- Search and Filter Logic ---
    function filterItems(gridId, searchTerm, filterType) {
        $(`#${gridId} .item-slot:not(.empty-slot)`).each(function() {
            let itemName = $(this).data('name') || "";
            let itemType = $(this).data('type') || "";

            let matchesSearch = itemName.toLowerCase().includes(searchTerm.toLowerCase());
            let matchesFilter = (filterType === "all" || itemType === filterType);

            if (matchesSearch && matchesFilter) {
                $(this).show();
            } else {
                $(this).hide();
            }
        });
    }

    // Event listeners for player inventory search & filter
    $("#player-search").on("input", function() {
        let searchTerm = $(this).val();
        let filterType = $("#player-inventory .filter-btn.active").data("filter") || "all";
        filterItems("player-inventory-grid", searchTerm, filterType);
    });

    $("#player-inventory .filter-btn").click(function() {
        $("#player-inventory .filter-btn").removeClass("active");
        $(this).addClass("active");

        let searchTerm = $("#player-search").val();
        let filterType = $(this).data("filter");
        filterItems("player-inventory-grid", searchTerm, filterType);
    });

    // Event listeners for secondary inventory search & filter
    $("#other-search").on("input", function() {
        let searchTerm = $(this).val();
        let filterType = $("#secondary-inventory .filter-btn.active").data("filter") || "all";
        filterItems("other-inventory-grid", searchTerm, filterType);
    });

    $("#secondary-inventory .filter-btn").click(function() {
        $("#secondary-inventory .filter-btn").removeClass("active");
        $(this).addClass("active");

        let searchTerm = $("#other-search").val();
        let filterType = $(this).data("filter");
        filterItems("other-inventory-grid", searchTerm, filterType);
    });

    // Interaction Buttons (Use, Give, Drop)
    $("#btn-use").click(function() {
        $.post('https://qb-inventory/useItem', JSON.stringify({}));
    });

    $("#btn-give").click(function() {
        $.post('https://qb-inventory/giveItem', JSON.stringify({}));
    });

    $("#btn-drop").click(function() {
        $.post('https://qb-inventory/dropItem', JSON.stringify({}));
    });
});
