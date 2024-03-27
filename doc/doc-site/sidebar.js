module.exports = {
  docs: [
    'welcome',
    {
      type: 'category',
      label: 'Move modules',
      link: {
        type: 'doc',
        id: 'move/modules'
      },
      items: [
        'move/changelog'
      ]
    },
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
    {
      type: 'category',
      label: 'Off-chain interfaces',
      link: {
        type: 'generated-index'
      },
      items: [
        'off-chain/events',
        'off-chain/python-sdk',
        'off-chain/rust-sdk',
        {
          type: 'category',
          label: 'Data service stack',
          link: {
            type: 'doc',
            id: 'off-chain/dss/data-service-stack'
          },
          items: [
            'off-chain/dss/changelog',
            'off-chain/dss/rest-api',
            'off-chain/dss/mqtt',
            'off-chain/dss/gcp',
            'off-chain/dss/terraform',
            'off-chain/dss/ci-cd',
          ]
        },
      ]
    },
    {
      type: 'category',
      label: 'Integrator resources',
      link: {
        type: 'generated-index'
      },
      items: [
        'integrators/econia-labs',
        'integrators/pyth',
        'integrators/bridges',
        'integrators/reference-frontend'
      ]
    },
    'security',
    'logo',
    'glossary'
  ]
}
