// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface GNSBorrowingFeesInterfaceV6_3_2 {
    // Structs
    struct PairGroup {
        uint16 groupIndex;
        uint48 block;
        uint64 initialAccFeeLong; // 1e10 (%)
        uint64 initialAccFeeShort; // 1e10 (%)
        uint64 prevGroupAccFeeLong; // 1e10 (%)
        uint64 prevGroupAccFeeShort; // 1e10 (%)
        uint64 pairAccFeeLong; // 1e10 (%)
        uint64 pairAccFeeShort; // 1e10 (%)
        uint64 _placeholder; // might be useful later
    }
    struct Pair {
        PairGroup[] groups;
        uint32 feePerBlock; // 1e10 (%)
        uint64 accFeeLong; // 1e10 (%)
        uint64 accFeeShort; // 1e10 (%)
        uint48 accLastUpdatedBlock;
        uint48 _placeholder; // might be useful later
        uint lastAccBlockWeightedMarketCap; // 1e40
    }
    struct Group {
        uint112 oiLong; // 1e10
        uint112 oiShort; // 1e10
        uint32 feePerBlock; // 1e10 (%)
        uint64 accFeeLong; // 1e10 (%)
        uint64 accFeeShort; // 1e10 (%)
        uint48 accLastUpdatedBlock;
        uint80 maxOi; // 1e10
        uint lastAccBlockWeightedMarketCap; // 1e40
    }
    struct InitialAccFees {
        uint64 accPairFee; // 1e10 (%)
        uint64 accGroupFee; // 1e10 (%)
        uint48 block;
        uint80 _placeholder; // might be useful later
    }
    struct PairParams {
        uint16 groupIndex;
        uint32 feePerBlock; // 1e10 (%)
    }
    struct GroupParams {
        uint32 feePerBlock; // 1e10 (%)
        uint80 maxOi; // 1e10
    }
    struct BorrowingFeeInput {
        address trader;
        uint pairIndex;
        uint index;
        bool long;
        uint collateral; // 1e18 (DAI)
        uint leverage;
    }
    struct LiqPriceInput {
        address trader;
        uint pairIndex;
        uint index;
        uint openPrice; // 1e10
        bool long;
        uint collateral; // 1e18 (DAI)
        uint leverage;
    }

    // Events
    event PairParamsUpdated(uint indexed pairIndex, uint16 indexed groupIndex, uint32 feePerBlock);
    event PairGroupUpdated(uint indexed pairIndex, uint16 indexed prevGroupIndex, uint16 indexed newGroupIndex);
    event GroupUpdated(uint16 indexed groupIndex, uint32 feePerBlock, uint80 maxOi);
    event TradeInitialAccFeesStored(
        address indexed trader,
        uint indexed pairIndex,
        uint index,
        uint64 initialPairAccFee,
        uint64 initialGroupAccFee
    );
    event TradeActionHandled(
        address indexed trader,
        uint indexed pairIndex,
        uint index,
        bool open,
        bool long,
        uint positionSizeDai // 1e18
    );
    event PairAccFeesUpdated(
        uint indexed pairIndex,
        uint currentBlock,
        uint64 accFeeLong,
        uint64 accFeeShort,
        uint accBlockWeightedMarketCap
    );
    event GroupAccFeesUpdated(
        uint16 indexed groupIndex,
        uint currentBlock,
        uint64 accFeeLong,
        uint64 accFeeShort,
        uint accBlockWeightedMarketCap
    );
    event GroupOiUpdated(
        uint16 indexed groupIndex,
        bool indexed long,
        bool indexed increase,
        uint112 amount,
        uint112 oiLong,
        uint112 oiShort
    );

    // Functions
    function getTradeLiquidationPrice(LiqPriceInput calldata) external view returns (uint); // PRECISION

    function getTradeBorrowingFee(BorrowingFeeInput memory) external view returns (uint); // 1e18 (DAI)

    function handleTradeAction(
        address trader,
        uint pairIndex,
        uint index,
        uint positionSizeDai, // 1e18 (collateral * leverage)
        bool open,
        bool long
    ) external;

    function withinMaxGroupOi(uint pairIndex, bool long, uint positionSizeDai) external view returns (bool);
}
