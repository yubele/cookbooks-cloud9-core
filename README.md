# cloud9-core-cookbook

TODO: Enter the cookbook description here.

## Supported Platforms

TODO: List your supported platforms.

## Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['cloud9-core']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Usage

### cloud9-core::default

Include `cloud9-core` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[cloud9-core::default]"
  ]
}
```

## License and Authors

Author:: yusuke@newsdict.net (<yusuke@newsdict.net>)
