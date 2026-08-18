// main template for capi-provider-cloudscale
local com = import 'lib/commodore.libjsonnet';
local kap = import 'lib/kapitan.libjsonnet';
local kube = import 'lib/kube.libjsonnet';
local inv = kap.inventory();
// The hiera parameters for the component
local params = inv.parameters.capi_provider_talos;

com.Kustomization(
  'https://github.com/siderolabs/cluster-api-control-plane-provider-talos/' + params.controlplane.kustomize.manifest_path,
  params.images['capi-controlplane-provider-talos'].tag,
  {
    'ghcr.io/siderolabs/cluster-api-control-plane-talos-controller': {
      local image = params.images['capi-controlplane-provider-talos'],
      newTag: image.tag,
      newName: '%(registry)s/%(image)s' % image,
    },
  },
  {
    namespace: params.namespace,
    labels+: [
      {
        pairs: {
          'app.kubernetes.io/managed-by': 'commodore',
        },
      },
    ],
    patchesStrategicMerge: [ 'rm-namespace.yaml' ],
  },
) {
  'rm-namespace': [
    {
      '$patch': 'delete',
      apiVersion: 'v1',
      kind: 'Namespace',
      metadata: {
        name: 'cacppt-system',
      },
    },
  ],
}
