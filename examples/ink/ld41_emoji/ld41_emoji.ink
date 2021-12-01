# author: Pat Scott
# title: ⏰
# description: Made for the Ludum Dare 41 Compo. The theme was "combine two incompatible genres." Thus, a textless text-based choose-your-own adventure.


VAR seenCat = false
VAR haveCoat = false
VAR time = 0

-> entre

=== increase_time ===

    ~ time ++
    ⏳

    -> DONE

=== entre ===

    = awaken
        +   (alarm) [⏰]
        -
        +   💤
                <>{|💤|💤💤|💤💤💤}
                {alarm < 4: -> awaken | -> angry_cat ->}
        *   [😫]

        //Morning prep loop

        -   (prep) {not seenCat:🐈}
            {time == 3: <>🕖}

            *   (petCat) {not seenCat} [👋]😽

            *   (fedCat) {seenCat} [🥫]😸💩

            *   (cleanedShit) {fedCat} [🥄]😼

            *   (showered) {not dressed} 🚿

            *   (ate) 🥞

            *   (dressed) 👔[]👖

        -   ~ seenCat = true
            <- increase_time
            {time < 4: -> prep}

        //End morning prep

        *   [🎒]
        -
        *   [🚪]
            * * {dressed} 🧣🧥
                🚪
            * * ->
        -   -> street


    = angry_cat
        *   [😾]
            ~ seenCat = true
        -
        *   [🤗]🤕
                <- increase_time
        ->->

    = street
        VAR coldness = 0
        ~ time = 0
        {awaken.dressed:
            ~ haveCoat = true

        }

        ❄️
        -> checkCold ->
        👣

        //Hobo encounter

        *   [🧔]🤲
            * * (hobo_gaveCoat) {haveCoat} [🧥]
                ~ haveCoat = false
                <- increase_time
                <>🙏
            * * (hobo_gaveMoney) [💸]
                <- increase_time
                <>🙏
            * * (hobo_fuckOff) [🖕]💨

        -   <- increase_time
            -> checkCold ->

        //Elder encounter

        *   [{~👵|👴}]♿
            * * (elder_chat) [💪]
                <- increase_time
                <>💬
            * * (elder_wave) [👋]
            * * (elder_horns) [🤘]🗯️

        -   <- increase_time
            -> checkCold ->

        //Getting on the train

        *   [🚇]🎫
            * * (police) {stolenCoat} [👮]️✋
                👉🧥
                *** [😇]🤥
                    ****[👁️]👌
                        <- increase_time
                *** [😈]💨
                    👣
            * * ->

            - - 🚃
            * * (mugger) {not police} {time < 5} [🕵️]🔪
                *** {not hobo_gaveMoney} {not boughtCoat} [💸]🖐️
                    🏃
                *** [😱]🕵👊💥
                    🏃
                    🤕
                    <- increase_time
                *** [😶]🔪{~👧|👦}
                        -> fight

            * * (on_train) ->

            - -
            <- increase_time
            <>
            <- increase_time


        -   -> adventure

    = checkCold
        {not haveCoat:
            ~ coldness ++
            <>🌡️
        }
        *   {coldness > 1} [🏬]
            * * 🧥[]🔖
                *** (boughtCoat) {not street.hobo_gaveMoney} [💸]🧥
                *** (stolenCoat) [🖐]🗯️❗
                    💨

                --- <- increase_time
                    ~haveCoat = true
        +   ->

        -   ->->

    = fight
        *{hobo_gaveCoat}[🧔🧥]🧔💪
            🧔👊
            **[🕵]💥
                👻
                👩👏
                🧔👩🤳
                -> on_train
        *[😣]
            **[😡]🔥
                ***[🙌]
                    ****[✊]
                        🤜
                        🤛
                        👊
                        *****[🕵]💥
                            👻
                            -> on_train
            **[🤡]
                🕵❗❓
                ***[💨]
                    ❄️
                    -> checkCold ->
                    👣
                    <- increase_time
                    <>
                    <- increase_time
                    <>
                    <- increase_time
                    <>
                    <- increase_time

                    -> adventure


=== adventure ===

    = arrival_at_office

        VAR got_written_up = false

        *   [🏢]
            **  [🗣️📋]
                {
                    - time < 5:
                        🕗
                    - time < 7:
                        🕣❗
                    - else:
                        🕘❗❗
                            ~ got_written_up = true
                }

                {not entre.awaken.dressed:
                    👖❗
                    ~ got_written_up = true
                }

                {not entre.awaken.showered:
                    🚿❗
                    ~ got_written_up = true
                }

        -
        *   {got_written_up} [📋]⚠️📜
            😅
        *   ->

        -
        *   [💻]👣
            💻

        //Work loop

        VAR ok_we_get_it_you_write_a_lot = false
        VAR work_loop = 0

        -   (computer)
            ~ work_loop++

            *   {work_loop > 4} [🔔]
                -> a_package

            *   {work_loop > 3} {not entre.awaken.cleanedShit} [👂]🎒
                -> cat_in_a_bag ->
                -> computer

            *   {work_loop > 2} {not entre.awaken.ate} [👃🥡]🚶
                🥡
                **  [🖐️]💨
                    *** [🥢]😋
                **  [😔]💻
                --  -> computer

            *   {work_loop > 2} {boredom} [🚽]🚭
                --  (toilet)
                **  {smoke} [💻]👣
                    -> computer
                ++  (squat) [📱]{~📑|🎮}
                    {squat > 3: -> shit}
                    <- increase_time
                    -> toilet
                **  (shit) [💩]🌊
                    👣
                    -> computer
                **  (smoke) [🚬]😉
                    -> toilet

            *   [🎧]🔊
                -> computer

            +   (write) {not ok_we_get_it_you_write_a_lot} [📝]
                {write > 3:
                    🗑️
                    <- increase_time
                    ~ ok_we_get_it_you_write_a_lot = true
                    -> computer
                }
                ✍️
                {write > 1: 🗑️}
                -> computer

            *   (boredom) [📰]👀
                😴
                -> computer

        -

        -> finale

    = cat_in_a_bag
        *   {not entre.awaken.fedCat} [😨]
            **  [😾]🤕
                🐾
        *   {entre.awaken.fedCat} [😲]😿
            **  [😙]
                🐈
                🐾

        -   ->->

    = a_package
        *   [📦]😮

        -   (contents)
        *   [🍄]💫
            -> dive_in
        *   [🔍]💭
            -> contents

        -   (dive_in)
        *   [😵]
            🤭
            👨‍🔧
            👩‍🚀
            👽
            🎇

        -
        *   [🌌]🌠
            🌈

        -
        +   (forest) 🌳[] 🏔️🏞️ 🌳🌳 🌳🌴 🌳 🌴 🌳 🌴🌴
            VAR have_crown = false

            ++  [🏔️]👣
                <-  increase_time
                -> mountain ->

            ++  {cat_in_a_bag} {not encounter} [🐾]
                <-  increase_time
                -> prints ->

            **  (rabbit) [🌳]
                -> chase

            ++  [🌴]🏖️🌊🏝️
                +++ {not have_crown} [🌞]♨️🌡️
                    👣

                *** {have_crown} [🌞]🌊 👸🔱👦🌊
                    🗨️👸👑

                    ****(ring) [👑]🌊 👸🔱🤴🌊
                        -> got_ring ->

                    ****[❌]🌊 🌊

                    ----👣

        -   -> forest

    = mountain
        🌋🗻 🏜️ 🗻

        +   [🌋]
            <- increase_time
            --  (volcano) 🔥🔥🌋🔥🔥
                {dragon > 1: 🗿}

            ++  (hole) {have_crown} {dragon < 2} [🕳️]
                --- (dragon) {dragon < 3: 🐉}

                *** [😎]🗨️🐲👑
                    ****{have_crown} [👑]
                        -> got_sword ->
                        -> volcano

                    ****(dont_give_crown) [❌]🔥🔥🔥🐲
                        😱💨
                        -> volcano

                *** {dont_give_crown} {have_crown} [👑]
                        -> got_sword ->
                        -> volcano

                *** [😘]🔥🔥🔥🐲
                    😅
                    -> hole

                +++ {not got_sword} [😱]{dragon > 1:🔥🔥🔥}💨
                    -> volcano

                +++ ->
                    <>💨
                    -> volcano


            ++  [🏔️️]
                <- increase_time

        +   [🏜️]
            <- increase_time
            <>💦
            {not desert:🌙}
            --  (desert) 🌵🌵 🌵 🌵🌵🌵
                {desert == 3:🦂💨}

            ++  {not have_crown} {not got_crown} [🌵]{not saw_crown: 😍}
                --- (saw_crown) 👑

                *** (got_crown) [🖐]🌟
                    ~ have_crown = true

                +++ [🔍]🔥<>
                    -> saw_crown

                +++ [↩️]


            **  [🌵]🦎
                *** [🦎]👁️
                    ****[🦎]👁️‍🗨️
                        🦎💨


            **  [🌵]🐍
                *** {entre.street.hobo_gaveMoney} [🧔💸]🧔💪
                    ****[🐍]💥
                        👻
                        🧔💨

                *** [😱]💥
                    😲
                    ****[😵]💯
                        <- increase_time
                        <>
                        <- increase_time
                        <>
                        <- increase_time
                        💤
                        *****[😫]
                            -> a_package.forest

            ++  [🏔️]{not comet:☄️}
                --- (comet)
                <- increase_time
                -> mountain

            --  -> desert


        +   [🌳]
            -> leave

        -   -> mountain

        -   (leave) 👣
            <- increase_time
            ->->

    = got_sword
        🗡️
        *   [🖐️]🌟
           ~ have_crown = false

        -   ->->

    = got_ring
        💍
        *   [🖐️]🌟
           ~ have_crown = false

        -   ->->

    = prints

        {flower > 2: 🌳}
        {bush: 🌿}
        {rabbit > 3: 🌳}

        +   (flower) {flower < 3} [🌳]
            ++  [🌷]{flower < 3: 👃|🌺}

        *   (encounter) 🦋[]🌿🐈
            **  (handsy) ️[🖐️]🐈💨

            **  (watchful) [🤐]🦋🐈
                😸
                💨

        *   (bush) {encounter} [🌿]🗝️
            **  (got_key) [🖐]🌟

            **  [😰]🌬️🗝️💨

        +   {rabbit < 4} [🌳]
            {not rabbit: 🐇💨}

            ++  {rabbit} [🌱]{rabbit < 3: 🍃|🍂}

            ++  ->

            --  (rabbit)

        +   [↩️]
            -> leave

        -   -> prints

        -   (leave) 👣
            <- increase_time
            ->->

    = chase
        *   [🐇]🐰
            **  [🐰]🐰💬
               🐇💨

        -
        *   [🐾]👣

        -   🌳🌟🎉✨
        +   [🎩]
        -   (tea_party)
            {tea_party < 2:🐇💨}
            {tea_party == 3 && encounter:🐈🐾}
            {tea_party < 4:✨<>}
            {tea_party < 5:
                {used_crown:🦄<>|🐴<>}
            }
            🍵
            {tea_party < 6:
                {used_crown:<>🐒|<>🕺}
            }
            {tea_party < 4:<>✨}


        -
        *   (used_crown) {have_crown} [👑]✨🎩✨
        *   (used_ring) {got_ring} {tea_party > 3} [💍]
            -> post_party

        +   {tea_party < 8} [🍵]

        *   {tea_party > 7} [😵]💯
            <- increase_time
            <>
            <- increase_time
            <>
            <- increase_time
            💤
            **[😫]
                -> post_party

        -   -> tea_party

        -   (post_party)
        +   [🌳]👣
            {not used_ring: 💫}

        -   -> finale

=== finale ===

    //The mystery and the credits

    *   {entre.street.hobo_fuckOff} [🧔🖕]🧔🗯️
        **  (flip_off) [🖕]🔫🧔
            ***  {adventure.got_sword} [🗡️]💪
                ****[🧔]💥
                    👻

            ***  [😱]💥
                -> fin

        **  [😐]🧔❗❓ {adventure.encounter:🐈|👐}
            *** {adventure.encounter} [🐈]😾
                💥
                🧔💨

            *** [🧥]🤝

            *** [🖕]
                -> flip_off
    *   ->

    -   (box) 📦 {adventure.encounter && not cat: 🐈}
    *   [🔍]🔒
    *   ->

    -
    *   {adventure.got_key} [🗝️]🔓
        **  [📦]🌌
            *** [😵]💫

    *   (cat) {adventure.encounter} [🐈]🙀
        🐾
        -> box

    *   [🤜]💥
        **  [🤛]💥
            *** [👊]💥
                ****📦[]🔒
                    😫
                    *****[✌️]

    -   (fin)
    *   [💤]
    -
    *   ⏰
        a short by Pat Scott
        🙏
    -   ->  END
