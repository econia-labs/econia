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
                'overview/market-accounts',
                'overview/matching'
            ]
        },
        {
            type: 'category',
            label: 'Move APIs',
            link: {
                type: 'doc',
                id: 'apis/index'
            },
            items: [
                'apis/registration',
                'apis/assets',
                'apis/trading',
                'apis/integrators',
                'apis/utility'
            ]
        },
        'off-chain',
        {
            type: 'category',
            label: 'Integrator resources',
            link: {
                type: 'generated-index'
            },
            items: [
                'integrators/econia-labs',
                'integrators/bridges',
                'integrators/notifications',
                'integrators/oracles',
                'integrators/audits',
            ]
        },
        'security',
        'logo'
    ]
}