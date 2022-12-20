module.exports = {
    docs: [
        'welcome',
        'modules',
        {
            type: 'category',
            label: 'Design overview',
            link: {
                type: 'doc',
                id: 'overview/index'
            },
            items: [
                'overview/orders',
                'overview/registry',
                'overview/incentives',
                'overview/market-account',
                'overview/matching'
            ]
        },
        'apis',
        'off-chain',
        'security',
        'third-party',
        'logo'
    ]
}