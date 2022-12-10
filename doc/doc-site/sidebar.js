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
                'overview/registry'
            ]
        },
        'off-chain',
        'logo'
    ]
}