---
title: MarketplaceService
type: raw-source
source_url: https://create.roblox.com/docs/reference/engine/classes/MarketplaceService
source_type: official-roblox-docs
source_repo: https://github.com/Roblox/creator-docs
source_yaml: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MarketplaceService.yaml
captured_at: 2026-04-16
captured_by: research-agent-1
category: economy
tags: [roblox-class, economy, monetization, purchases]
---

# MarketplaceService

The service responsible for in-experience transactions.

## Description

`Class.MarketplaceService` is responsible for in-experience transactions. The
most notable methods are
`Class.MarketplaceService:PromptProductPurchase()|PromptProductPurchase` and
`Class.MarketplaceService:PromptPurchase()|PromptPurchase`, as well as the
callback `Class.MarketplaceService.ProcessReceipt|ProcessReceipt` which must
be defined so that developer product transactions do not fail.

`Class.MarketplaceService` also has methods that fetch information about
[developer products](../../../production/monetization/developer-products.md)
(`Class.MarketplaceService:GetProductInfoAsync()|GetProductInfoAsync` and
`Class.MarketplaceService:GetDeveloperProductsAsync()|GetDeveloperProductsAsync`),
[passes](../../../production/monetization/passes.md)
(`Class.MarketplaceService:UserOwnsGamePassAsync()|UserOwnsGamePassAsync()`),
and other assets
(`Class.MarketplaceService:PlayerOwnsAssetAsync()|PlayerOwnsAssetAsync`,
`Class.MarketplaceService:PlayerOwnsBundleAsync()|PlayerOwnsBundleAsync`).

Understanding `Class.MarketplaceService` is the first step towards learning to
[monetize](../../../production/monetization/index.md) an experience on Roblox,
as well as learning to use `Class.DataStoreService`, which is responsible for
saving and loading all data related to purchases.

## Inheritance

Inherits from: `Instance`

Class tags: `NotCreatable`, `Service`

Memory category: `Instances`

## Properties

_No public properties documented._

## Methods

### `MarketplaceService:GetDeveloperProductsAsync`

```
GetDeveloperProductsAsync() -> Instance
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`AssetRead`

Returns a `Class.Pages` object which contains information for all of the
current experience's developer products.

Returns a `Class.Pages` object which contains information for all of the
current experience's
[developer products](../../../production/monetization/developer-products.md).

**Returns:**

- `Instance` — 

### `MarketplaceService:GetProductInfo`

```
GetProductInfo(assetId: int64, infoType: InfoType = Asset) -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`AssetRead` ; **Deprecated:** This method has been superseded by
`Class.MarketplaceService.GetProductInfoAsync|GetProductInfoAsync()`.

Returns the product information of an asset using its asset ID.

**Parameters:**

- `assetId` : `int64` — The asset ID of the specified product.
- `infoType` : `InfoType` (default `Asset`) — An `Enum.InfoType` enum value specifying the type of information being retrieved.

**Returns:**

- `Dictionary` — A dictionary containing information about the queried item, described in the previous tables.

### `MarketplaceService:GetProductInfoAsync`

```
GetProductInfoAsync(assetId: int64, infoType: InfoType = Asset) -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`AssetRead`

Returns the product information of an asset using its asset ID.

This method provides information about an asset,
[developer product](../../../production/monetization/developer-products.md),
or [pass](../../../production/monetization/passes.md) based on the asset
ID and the `Enum.InfoType`. If an item with the given ID does not exist,
this method throws an error.

Information about the queried item is provided in a dictionary with the
following keys. Note that not all information is provided or necessarily
relevant for the kind of product you're querying.

<table size="small">
	<thead>
	  <tr>
	    <th>Key</th>
	    <th>Type</th>
	    <th>Description</th>
	  </tr>
	</thead>
  <tbody>
	<tr>
	  <td><code>Name</code></td>
	  <td>string</td>
	  <td>The name shown on the asset's page.</td>
  </tr>
	<tr>
	  <td><code>Description</code></td>
	  <td>string</td>
	  <td>The description shown on the asset's page; can be <code>nil</code> if blank.</td>
  </tr>
	<tr>
	  <td><code>PriceInRobux</code></td>
	  <td>number</td>
	  <td>The cost of purchasing the asset using Robux.</td>
  </tr>
  <tr>
	  <td><code>UserBasePriceInRobux</code></td>
	  <td>number</td>
	  <td>The base price of the asset in Robux before any discounts are applied.</td>
  </tr>
  <tr>
	  <td><code>PriceDiscountDetails</code></td>
	  <td>Array</td>
	  <td>An ordered list of discounts representing the difference between <code>UserBasePriceInRobux</code> and <code>PriceInRobux</code>. Each entry contains the following keys:</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
	  <td><code>Type</code>: The type of discount. <code>"RobloxPlusSubscription"</code> indicates that the discount was applied due to the user’s Roblox Plus subscription.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
	  <td><code>AmountInRobux</code>: number — The value of the discount in Robux.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
	  <td><code>Percent</code>: number — The percentage of the discount.</td>
  </tr>
  <tr>
	  <td><code>ProductId</code></td>
	  <td>number</td>
	  <td>The product ID if <code>Enum.InfoType</code> is <code>Product</code>.</td>
  </tr>
  <tr>
	  <td><code>ProductType</code></td>
	  <td>string</td>
	  <td>A string describing what the product is. Not to be confused with <code>Enum.MarketplaceProductType</code>.</td>
  </tr>
	<tr>
	  <td><code>Created</code></td>
	  <td>string</td>
	  <td>Timestamp of when the asset was created, for example <code>2022-01-02T10:30:45Z</code>. Formatted using ISO 8601.</td>
  </tr>
	<tr>
	  <td><code>Updated</code></td>
	  <td>string</td>
	  <td>Timestamp of when the asset was last updated by its creator, for example <code>2022-02-12T11:22:15Z</code>. Formatted using ISO 8601.</td>
  </tr>
	<tr>
	  <td><code>ContentRatingTypeId</code></td>
	  <td>number</td>
	  <td>Indicates whether the item is marked as 13+ in catalog.</td>
  </tr>
	<tr>
	  <td><code>MinimumMembershipLevel</code></td>
	  <td>number</td>
	  <td>The minimum subscription level necessary to purchase the item.</td>
  </tr>
	<tr>
	  <td><code>IsPublicDomain</code></td>
	  <td>boolean</td>
	  <td>Describes whether the asset can be taken for free.</td>
  </tr>
  <tr>
	  <td><code>TargetId</code></td>
	  <td>number</td>
	  <td>The ID of the product or asset.</td>
  </tr>
  </tbody>
</table>

##### Creator Information

<table size="small">
  <thead>
	  <tr>
	    <th>Key</th>
	    <th>Type</th>
	    <th>Description</th>
	  </tr>
	</thead>
  <tbody>
	<tr>
	  <td><code>Creator</code></td>
	  <td>table</td>
	  <td>Dictionary table of information describing the creator of the asset, containing the following fields:</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>CreatorType</code>: Either <code>User</code> or <code>Group</code>.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>CreatorTargetId</code>: The ID of the creator user or group.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>HasVerifiedBadge</code>: Boolean of whether the creator has a verified badge.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>Name</code>: The name/username of the creator.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>Id</code>: Use <code>CreatorTargetId</code> instead.</td>
  </tr>
  </tbody>
</table>

##### Asset Information

<table size="small">
  <thead>
	  <tr>
	    <th>Key</th>
	    <th>Type</th>
	    <th>Description</th>
	  </tr>
	</thead>
  <tbody>
	<tr>
	  <td><code>AssetId</code></td>
	  <td>number</td>
	  <td>The asset ID if <code>Enum.InfoType</code> is <code>Asset</code>.</td>
  </tr>
	<tr>
	  <td><code>AssetTypeId</code></td>
	  <td>number</td>
	  <td>The type of asset. See <code>Enum.AssetType</code> for the asset type ID numbers.</td>
  </tr>
  <tr>
	  <td><code>IconImageAssetId</code></td>
	  <td>number</td>
	  <td>The asset ID of the product's icon, or <code>0</code> if there isn't one.</td>
  </tr>
	<tr>
	  <td><code>IsForSale</code></td>
	  <td>boolean</td>
	  <td>Describes whether the asset is purchasable.</td>
  </tr>
	<tr>
	  <td><code>IsLimited</code></td>
	  <td>boolean</td>
	  <td>Describes whether the asset is a Roblox Limited that is no longer (if ever) sold.</td>
  </tr>
	<tr>
	  <td><code>IsLimitedUnique</code></td>
	  <td>boolean</td>
	  <td>Describes whether the asset is a unique Roblox Limited ("Limited&nbsp;U") item that only has a fixed number sold.</td>
  </tr>
	<tr>
	  <td><code>IsNew</code></td>
	  <td>boolean</td>
	  <td>Describes whether the asset is marked as "new" in the catalog.</td>
  </tr>
	<tr>
	  <td><code>Remaining</code></td>
	  <td>number</td>
	  <td>The remaining number of times a limited unique item may be sold.</td>
  </tr>
	<tr>
	  <td><code>Sales</code></td>
	  <td>number</td>
	  <td>The number of times the asset has been sold.</td>
  </tr>
  </tbody>
</table>

##### Collectibles Information

<table size="small">
  <thead>
	  <tr>
	    <th>Key</th>
	    <th>Type</th>
	    <th>Description</th>
	  </tr>
	</thead>
  <tbody>
  <tr>
	  <td><code>CollectibleItemId</code></td>
	  <td>string</td>
	  <td>The unique item ID of the collectible.</td>
  </tr>
	<tr>
	  <td><code>CollectibleProductId</code></td>
	  <td>string</td>
	  <td>The unique product ID of the collectible.</td>
  </tr>
  <tr>
	  <td><code>CollectiblesItemDetails</code></td>
	  <td>table</td>
	  <td>Dictionary table of information describing the collectible, containing the following fields:</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>CollectibleLowestAvailableResaleItemInstanceId</code>: The unique item instance ID of the lowest available resale for the collectible.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>CollectibleLowestAvailableResaleProductId</code>: The unique product ID of the lowest available resale for the collectible.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>CollectibleLowestResalePrice</code>: The lowest resale price for the collectible in Robux.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>IsForSale</code>: Boolean of whether the collectible is available for sale (not resale).</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>IsLimited</code>: Boolean of whether or not the collectible is limited.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
    <td><code>TotalQuantity</code>: The total quantity of the collectible available for purchase (not resale).</td>
  </tr>
  </tbody>
</table>

##### Sale Location Settings

<table size="small">
  <thead>
	  <tr>
	    <th>Key</th>
	    <th>Type</th>
	    <th>Description</th>
	  </tr>
	</thead>
  <tbody>
	<tr>
	  <td><code>CanBeSoldInThisGame</code></td>
	  <td>boolean</td>
	  <td>Describes whether the asset is purchasable in the current experience.</td>
  </tr>
  <tr>
	  <td><code>SaleLocation</code></td>
	  <td>table</td>
	  <td>Dictionary table of information describing where the item can be sold, containing the following fields:</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
	  <td><code>SaleLocationType</code>: The type of sale location setting. See <code>Enum.ProductLocationRestriction</code> for the sale location setting ID numbers.</td>
  </tr>
  <tr>
	  <td colspan="2"></td>
	  <td><code>UniverseIds</code>: Array table of universes in which the item can be sold (not currently implemented).</td>
  </tr>
  </tbody>
</table>

**Parameters:**

- `assetId` : `int64` — The asset ID of the specified product.
- `infoType` : `InfoType` (default `Asset`) — An `Enum.InfoType` enum value specifying the type of information being retrieved.

**Returns:**

- `Dictionary` — A dictionary containing information about the queried item, described in the previous tables.

### `MarketplaceService:GetRobloxSubscriptionDetailsAsync`

```
GetRobloxSubscriptionDetailsAsync(user: Player) -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Monetization`

Returns the subscription details for the given user for the Roblox
Subscription ecosystem.

This method is a streamlined endpoint to check for a single, platform-wide
Roblox subscription product. By providing `StartTime` (conditionally) and
`IsOriginExperience` to reward long-term loyalists without compromising
user data across the platform.

The returned dictionary contains the following fields:

<table size="small">
  <thead>
    <tr>
      <th>Field</th>
      <th>Type</th>
      <th>Description</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><code>IsSubscribed</code></td>
      <td>bool</td>
      <td>Returns true if the user has an active Roblox Subscription membership.</td>
    </tr>
    <tr>
      <td><code>IsOriginExperience</code></td>
      <td>bool</td>
      <td>Returns true if the user originally subscribed to Roblox Subscription while inside the current Experience (Universe).</td>
    </tr>
    <tr>
      <td><code>StartTime</code></td>
      <td>DateTime?</td>
      <td>A <code>Datatype.DateTime</code> object representing the time when the user’s subscription period first began. Note: For privacy reasons, this field is only returned if <code>IsOriginExperience</code> is true. If the user subscribed in a different experience or on the web, this field will be nil.</td>
    </tr>
  </tbody>
</table>

**Parameters:**

- `user` : `Player` — The user regarding whom to check the subscription status.

**Returns:**

- `Dictionary` — A dictionary containing subscription details such as `IsSubscribed`, `IsOriginExperience`, and optionally `StartTime`.

### `MarketplaceService:GetSubscriptionProductInfoAsync`

```
GetSubscriptionProductInfoAsync(subscriptionId: string) -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`AssetRead`

Returns the product information of a subscription for the given
`subscriptionId`.

**Note**: Because it returns a localized price, you can only call this
method from a `Class.Script` with `Enum.RunContext.Client`.

Returns the product information of a subscription for the given
`subscriptionId`.

<table size="small">
	<thead>
	  <tr>
	    <th>Key</th>
	    <th>Type</th>
	    <th>Description</th>
	  </tr>
	</thead>
  <tbody>
	<tr>
	  <td><code>Name</code></td>
	  <td>string</td>
	  <td>The name of the subscription product.</td>
  </tr>
	<tr>
	  <td><code>Description</code></td>
	  <td>string</td>
	  <td>The description of the subscription product.</td>
  </tr>
	<tr>
	  <td><code>IconImageAssetId</code></td>
	  <td>number</td>
    <td>The asset ID of the subscription product icon.</td>
  </tr>
	<tr>
	  <td><code>SubscriptionPeriod</code></td>
	  <td><code>Enum.SubscriptionPeriod</code></td>
    <td>The duration of the subscription (for example, <code>Month</code>, <code>Year</code>, etc.).</td>
  </tr>
	<tr>
	  <td><code>DisplayPrice</code></td>
	  <td>string</td>
    <td>Localized price with the appropriate currency symbol for display (for example, <code>$4.99</code>). For users in unsupported countries, <code>DisplayPrice</code> returns a string without specific price information.</td>
  </tr>
	<tr>
	  <td><code>DisplaySubscriptionPeriod</code></td>
	  <td>string</td>
    <td>Localized subscription period text for display (for example, <code>/month</code>). Can be used together with <code>DisplayPrice</code>.</td>
  </tr>
	<tr>
	  <td><code>SubscriptionProviderName</code></td>
	  <td>string</td>
    <td>Name of the subscription benefit provider (for example, the name of the associated experience).</td>
  </tr>
	<tr>
	  <td><code>IsForSale</code></td>
	  <td>boolean</td>
	  <td>True if the subscription product is available for sale.</td>
  </tr>
  <tr>
	  <td><code>PriceTier</code></td>
	  <td>number</td>
	  <td>A number that can be used to compare the price of different subscription products. This is not the actual price of the subscription (for example, 499).</td>
  </tr>
  <tr>
      	  <td><code>PriceInRobux</code></td>
      	  <td>number</td>
      	  <td>The equivalent cost of the subscription in Robux. Returns 0 if the subscription product is not available to be purchased in Robux.</td>
  </tr>
  </tbody>
</table>

**Parameters:**

- `subscriptionId` : `string` — The ID of the subscription to check.

**Returns:**

- `Dictionary` — 

### `MarketplaceService:GetUsersPriceLevelsAsync`

```
GetUsersPriceLevelsAsync(userIds: Array) -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Monetization`

Returns the regionalized price level of a user, representing the
recommended price for an item in their regional market.

Returns the regionalized price level of a user, representing the
recommended price for an item in their regional market. For example, a
price level of 100 means that the suggested price for that user (based on
their region and purchasing power) is 100 Robux.

See
[Protect your trades and gifts](../../../production/monetization/regional-pricing.md#protect-your-trades-and-gifts)
for more information.

**Parameters:**

- `userIds` : `Array` — An array of user IDs.

**Returns:**

- `Array` — Returns an array of `PriceLevelInfo` objects with a dictionary where the keys are user IDs (strings) and their values are the corresponding price levels (integers between 1 and 1000).

### `MarketplaceService:GetUserSubscriptionDetailsAsync`

```
GetUserSubscriptionDetailsAsync(user: Player, subscriptionId: string) -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Monetization`

Returns a table that contains the details of the user's subscription for a
given `subscriptionId`.

Returns a dictionary table containing the details of the user's
subscription for the given `subscriptionId`. The table contains the
following keys:

<table size="small">
	<thead>
	  <tr>
	    <th>Key</th>
	    <th>Type</th>
	    <th>Description</th>
	  </tr>
	</thead>
  <tbody>
	<tr>
	  <td><code>SubscriptionState</code></td>
	  <td><code>Enum.SubscriptionState</code></td>
	  <td>Current state of this particular subscription.</td>
  </tr>
	<tr>
	  <td><code>NextRenewTime</code></td>
	  <td><code>Datatype.DateTime</code></td>
	  <td>
      Renewal time for this current subscription. May be in the past if the subscription is in
      <code>Enum.SubscriptionState.SubscribedRenewalPaymentPending|SubscribedRenewalPaymentPending</code> state. This
      field is will be <code>nil</code> if the subscription will not renew, is <code>Enum.SubscriptionState.Expired|Expired</code>, or the user never subscribed.
    </td>
  </tr>
  <tr>
	  <td><code>ExpireTime</code></td>
	  <td><code>Datatype.DateTime</code></td>
	  <td>
      When this subscription expires. This field will be <code>nil</code>
      if the subscription is not cancelled or the user never subscribed.
    </td>
  </tr>
  <tr>
	  <td><code>ExpirationDetails</code></td>
	  <td><code>Library.table</code></td>
	  <td>
      Table containing the details of the subscription expiration. This
      field will be <code>nil</code> if the subscription is not in the
      <code>Enum.SubscriptionState.Expired|Expired</code> state. If populated, the table contains a <code>ExpirationReason</code> key of type <code>Enum.SubscriptionExpirationReason</code> describing why the subscription is expired.
    </td>
  </tr>
  </tbody>
</table>

Note that this method can only be called from a `Class.Script` with
`Class.BaseScript.RunContext|RunContext` of
`Enum.RunContext.Server|Server`. If you only need to determine the
`IsSubscribed` status of a user, it's recommended to use
`Class.MarketplaceService:GetUserSubscriptionStatusAsync()|GetUserSubscriptionStatusAsync`
as it is faster and more efficient for that particular purpose.

**Parameters:**

- `user` : `Player` — The `Class.Player` object whose subscription details you want to check.
- `subscriptionId` : `string` — The ID of the subscription to check.

**Returns:**

- `Dictionary` — 

### `MarketplaceService:GetUserSubscriptionPaymentHistoryAsync`

```
GetUserSubscriptionPaymentHistoryAsync(user: Player, subscriptionId: string) -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Monetization`

Returns an `Library.table|Array` that contains up to one year of the
user's subscription payment history for the given `subscriptionId`.

**Note**: You can only call this method from a `Class.Script` with
`Enum.RunContext.Server`.

Returns an `Library.table|Array` that contains up to one year of the
user's subscription payment history for the given `subscriptionId`, sorted
from the most recent status to the least recent.

Each entry in the payment history `Library.table|Array` contains the
following keys:

<table size="small">
	<thead>
	  <tr>
	    <th>Key</th>
	    <th>Type</th>
	    <th>Description</th>
	  </tr>
	</thead>
  <tbody>
	<tr>
	  <td><code>CycleStartTime</code></td>
	  <td><code>Datatype.DateTime</code></td>
	  <td><code>Datatype.DateTime</code> at the start of this particular subscription period.</td>
  </tr>
	<tr>
	  <td><code>CycleEndTime</code></td>
	  <td><code>Datatype.DateTime</code></td>
	  <td><code>Datatype.DateTime</code> at the end of this particular subscription period.</td>
  </tr>
  <tr>
	  <td><code>PaymentStatus</code></td>
	  <td><code>Enum.SubscriptionPaymentStatus</code></td>
	  <td><code>Enum.SubscriptionPaymentStatus.Paid</code> if the user paid for this particular subscription period.
    <code>Enum.SubscriptionPaymentStatus.Refunded</code> if the user refunded this particular subscription period.
    </td>
  </tr>
  </tbody>
</table>

#### Payment History Length

Only creators affiliated with the subscription product can access up to
**one year** worth of the user's subscription payment history.
Non-associated creators can only get the user's **current** subscription
payment status or an empty `Library.table|Array` if the user has no active
subscription.

#### Grace Period

Subscription renewal payments can have some processing time. Payment
history doesn't return a table for this period. However, in order to
preserve a user's subscription experience during the processing period,
`Class.MarketplaceService.GetUserSubscriptionStatusAsync()|GetUserSubscriptionStatusAsync`
returns `IsSubscribed: true` for the given user. Don't grant durable items
or currency type subscription benefits to the user until after payment has
been confirmed for the current cycle.

For example, on August 31, 2023, User A's Subscription B is up for
renewal. On September 1, 2023, the payment has yet to be processed. If you
call
`Class.MarketplaceService.GetUserSubscriptionPaymentHistoryAsync()|GetUserSubscriptionPaymentHistoryAsync`
on September 1, 2023 on User A for Subscription B, the first entry of the
return value is:

<table size="small">
	<thead>
	  <tr>
	    <th>Key</th>
	    <th>Value</th>
	  </tr>
	</thead>
  <tbody>
	<tr>
	  <td><code>CycleStartTime</code></td>
	  <td>...</td>
  </tr>
	<tr>
	  <td><code>CycleEndTime</code></td>
	  <td>August 31, 2023</td>
  </tr>
  <tr>
	  <td><code>PaymentStatus</code></td>
	  <td><code>Enum.SubscriptionPaymentStatus.Paid</code></td>
  </tr>
  </tbody>
</table>

Note that since the user is within the grace period, the cycle they have
yet to pay for (September 1, 2023) does not appear in the return value at
all. This field only populates after the payment has been received and
processed.

At the same time,
`Class.MarketplaceService.GetUserSubscriptionStatusAsync()|GetUserSubscriptionStatusAsync`
returns the following result until the renewal payment process fails or
the user cancels:

<table size="small">
	<thead>
	  <tr>
	    <th>Key</th>
	    <th>Return</th>
	  </tr>
	</thead>
  <tbody>
	<tr>
	  <td><code>IsSubscribed</code></td>
	  <td>True</td>
  </tr>
	<tr>
	  <td><code>IsRenewing</code></td>
	  <td>True</td>
  </tr>
  </tbody>
</table>

**Parameters:**

- `user` : `Player` — 
- `subscriptionId` : `string` — 

**Returns:**

- `Array` — 

### `MarketplaceService:GetUserSubscriptionStatusAsync`

```
GetUserSubscriptionStatusAsync(user: Player, subscriptionId: string) -> Dictionary
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`Monetization`

Returns a `Library.table` that contains the subscription status of the
user for the given `subscriptionId`.

Returns a `Library.table` that contains the subscription status of the
user for the given `subscriptionId`. The table contains the following
keys:

<table size="small">
	<thead>
	  <tr>
	    <th>Key</th>
	    <th>Type</th>
	    <th>Description</th>
	  </tr>
	</thead>
  <tbody>
	<tr>
	  <td><code>IsSubscribed</code></td>
	  <td>boolean</td>
	  <td>True if the user's subscription is active.</td>
  </tr>
	<tr>
	  <td><code>IsRenewing</code></td>
	  <td>boolean</td>
	  <td>True if the user is set to renew this subscription after the current subscription period ends.</td>
  </tr>
  </tbody>
</table>

Note that `IsSubscribed` will be `true` only when a user has purchased the
subscription and the payment has been successfully processed. If the
payment for a user's initial subscription purchase is still processing or
has failed, `IsSubscribed` returns `false`. To understand when a user's
subscription status has changed, see the
`Class.Players.UserSubscriptionStatusChanged` event.

**Parameters:**

- `user` : `Player` — The `Class.Player` object whose subscription status you want to check.
- `subscriptionId` : `string` — The ID of the subscription to check for.

**Returns:**

- `Dictionary` — 

### `MarketplaceService:PlayerOwnsAsset`

```
PlayerOwnsAsset(player: Instance, assetId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`AssetRead` ; **Deprecated:** This method has been superseded by
`Class.MarketplaceService:PlayerOwnsAssetAsync()|PlayerOwnsAssetAsync()`.

Returns whether the given user has the given asset.

**Parameters:**

- `player` : `Instance` — The `Class.Player` whose inventory is tested for ownership of the given asset.
- `assetId` : `int64` — The asset ID for which the given player's inventory is tested.

**Returns:**

- `boolean` — Indicates whether the given player's inventory contains the given asset.

### `MarketplaceService:PlayerOwnsAssetAsync`

```
PlayerOwnsAssetAsync(player: Instance, assetId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`AssetRead`

Returns whether the given user has the given asset.

Returns whether the inventory of a specific user contains an asset, based
on the asset ID. This method throws an error if the query fails, so you
should wrap calls to this method in `pcall()`.

- This method should **not** be used for
  [passes](../../../production/monetization/passes.md) since they use a
  separate ID system. Legacy passes that still depend on an asset ID
  should use
  `Class.MarketplaceService:UserOwnsGamePassAsync()|UserOwnsGamePassAsync()`
  instead of this method.
- This method cannot be used to check for
  [developer products](../../../production/monetization/developer-products.md)
  since they can be purchased multiple times but not owned themselves.
  Instead, use a [data store](../../../cloud-services/data-stores) to save
  when a user buys a developer product.

**Parameters:**

- `player` : `Instance` — The `Class.Player` whose inventory is tested for ownership of the given asset.
- `assetId` : `int64` — The asset ID for which the given player's inventory is tested.

**Returns:**

- `boolean` — Indicates whether the given player's inventory contains the given asset.

### `MarketplaceService:PlayerOwnsBundle`

```
PlayerOwnsBundle(player: Player, bundleId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`, `Deprecated` ; capabilities=`AssetRead` ; **Deprecated:** This method has been superseded by
`Class.MarketplaceService:PlayerOwnsBundleAsync()|PlayerOwnsBundleAsync()`.

Returns whether the given player owns the given bundle.

**Parameters:**

- `player` : `Player` — The `Class.Player` whose inventory is tested for ownership of the given bundle.
- `bundleId` : `int64` — The bundle ID for which the given player's inventory is tested.

**Returns:**

- `boolean` — Indicates whether the given player's inventory contains the given bundle.

### `MarketplaceService:PlayerOwnsBundleAsync`

```
PlayerOwnsBundleAsync(player: Player, bundleId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`AssetRead`

Returns whether the given player owns the given bundle.

Returns whether the inventory of a specific user contains a bundle, based
on the bundle ID. This method throws an error if the query fails, so you
should wrap calls to this method in `pcall()`.

**Parameters:**

- `player` : `Player` — The `Class.Player` whose inventory is tested for ownership of the given bundle.
- `bundleId` : `int64` — The bundle ID for which the given player's inventory is tested.

**Returns:**

- `boolean` — Indicates whether the given player's inventory contains the given bundle.

### `MarketplaceService:PromptBulkPurchase`

```
PromptBulkPurchase(player: Player, lineItems: Array, options: Dictionary) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`PromptExternalPurchase`

Prompts a user to purchase multiple avatar items with the given `assetId`
or `bundleId`.

Prompts a user to purchase multiple avatar items with the given `assetId`
or `bundleId`. Does not work with non-avatar items.

`PromptBulkPurchase` only allows prompting from server scripts.

For limited items, original copies are prompted until they run out,
regardless of the price. Once original copies are out, resale copies are
prompted.

A maximum of 20 items can be added to a single bulk purchase prompt.

**Parameters:**

- `player` : `Player` — The user to prompt to purchase items.
- `lineItems` : `Array` — An array of avatar items to be included in the bulk purchase.  Each line item contains the following structure:  ```lua {   Type: MarketplaceProductType,   Id: string } ```  Each line item contains the following pairs:  - `Type`: The corresponding `Enum.MarketplaceProductType` (Enum). - `Id`: The ID of the asset or bundle.
- `options` : `Dictionary` — Not available at this time.

**Returns:**

- `()` — 

### `MarketplaceService:PromptBundlePurchase`

```
PromptBundlePurchase(player: Instance, bundleId: int64) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`PromptExternalPurchase`

Prompts a user to purchase a bundle with the given `bundleId`.

**Parameters:**

- `player` : `Instance` — 
- `bundleId` : `int64` — 

**Returns:**

- `()` — 

### `MarketplaceService:PromptCancelSubscription`

```
PromptCancelSubscription(user: Player, subscriptionId: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`PromptExternalPurchase`

Prompts a user to cancel a subscription for the given `subscriptionId`.

Prompts a user to cancel a subscription for the given `subscriptionId`.
Once the user successfully cancels the subscription, the
`Class.Players.UserSubscriptionStatusChanged` event fires.

**Parameters:**

- `user` : `Player` — 
- `subscriptionId` : `string` — 

**Returns:**

- `()` — 

### `MarketplaceService:PromptGamePassPurchase`

```
PromptGamePassPurchase(player: Instance, gamePassId: int64) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`PromptExternalPurchase`

Prompts a user to purchase a pass with the given `gamePassId`.

Prompts a user to purchase a
[pass](../../../production/monetization/passes.md) with the given
`gamePassId`.

**Parameters:**

- `player` : `Instance` — 
- `gamePassId` : `int64` — 

**Returns:**

- `()` — 

### `MarketplaceService:PromptPremiumPurchase`

```
PromptPremiumPurchase(player: Instance) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`PromptExternalPurchase` ; **Deprecated:** This method has been superseded by
`Class.MarketplaceService:PromptRobloxSubscriptionPurchase()|PromptRobloxSubscriptionPurchase()`.

Prompts a user to purchase Roblox Premium.

Prompts a user to purchase
[Roblox Premium](https://www.roblox.com/premium/membership). To learn more
about Premium and about incorporating Premium incentives into your
experience, see
[Engagement-based payouts](../../../production/monetization/engagement-based-payouts.md).

##### See also

- `Class.MarketplaceService.PromptPremiumPurchaseFinished` which fires
  when the Premium purchase UI closes.
- `Class.Players.PlayerMembershipChanged` which fires when the server
  recognizes that a user's membership has changed.

**Parameters:**

- `player` : `Instance` — The user being prompted to purchase Premium.

**Returns:**

- `()` — 

### `MarketplaceService:PromptProductPurchase`

```
PromptProductPurchase(player: Instance, productId: int64, equipIfPurchased: boolean = True, currencyType: CurrencyType = Default) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`PromptExternalPurchase`

Prompts a user to purchase a developer product with the given `productId`.

Prompts a user to purchase a
[developer product](../../../production/monetization/developer-products.md)
with the given `productId`.

**Parameters:**

- `player` : `Instance` — 
- `productId` : `int64` — 
- `equipIfPurchased` : `boolean` (default `True`) — 
- `currencyType` : `CurrencyType` (default `Default`) — 

**Returns:**

- `()` — 

### `MarketplaceService:PromptPurchase`

```
PromptPurchase(player: Instance, assetId: int64, equipIfPurchased: boolean = True, currencyType: CurrencyType = Default) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`PromptExternalPurchase`

Prompts a user to purchase an item with the given `assetId`. Does not work
for USD Creator Store purchases.

Prompts a user to purchase an item with the given `assetId`.

- This does not work for
  [USD Creator Store](../../../production/creator-store.md) purchases.
- If the item has the
  [Sale Location](../../../marketplace/publish-to-marketplace.md#sale-location)
  set as `Experience By Place ID (API Only)`, you must call
  `Class.MarketplaceService:PromptPurchase` from a server script.
- If prompting a purchase of a
  [limited](../../../marketplace/marketplace-fees-and-commissions.md#limiteds)
  item:
  - (Recommended) Server requests prompt original copies until they run
    out, regardless of the price. Once original copies run out, resale
    copies are prompted.
  - Client requests prompt from the lowest resale price even if original
    copies are available.

**Parameters:**

- `player` : `Instance` — 
- `assetId` : `int64` — 
- `equipIfPurchased` : `boolean` (default `True`) — 
- `currencyType` : `CurrencyType` (default `Default`) — Ignored.

**Returns:**

- `()` — 

### `MarketplaceService:PromptRobloxSubscriptionPurchase`

```
PromptRobloxSubscriptionPurchase(user: Player) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`PromptExternalPurchase`

Prompts a user to purchase a Roblox Plus subscription.

Prompts a user to purchase a Roblox Plus subscription. When the user
successfully subscribes, any experience-defined rewards for the upsell are
granted automatically through the engine API.

##### See also

- `Class.MarketplaceService.PromptRobloxSubscriptionPurchaseFinished`
  which fires when the Roblox Plus purchase UI closes.
- `Class.Player.HasRobloxSubscription` which can be observed via
  `Class.Instance:GetPropertyChangedSignal()` to detect when a user's
  subscription status changes.

**Parameters:**

- `user` : `Player` — The `Class.Player` to be prompted to purchase Roblox Plus.

**Returns:**

- `()` — 

### `MarketplaceService:PromptSubscriptionPurchase`

```
PromptSubscriptionPurchase(user: Player, subscriptionId: string) -> ()
```

- security=`None` ; thread-safety=`Unsafe` ; capabilities=`PromptExternalPurchase`

Prompts a user to purchase a subscription for the given `subscriptionId`.

**Parameters:**

- `user` : `Player` — The `Class.Player` object to be prompted to subscribe.
- `subscriptionId` : `string` — The ID of the subscription to subscribe to.

**Returns:**

- `()` — 

### `MarketplaceService:RankProductsAsync`

```
RankProductsAsync(productIdentifiers: Array) -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`

Takes a list of product IDs and returns a personalized ordered list of
those products.

Takes a list of product IDs and returns a personalized ordered list of
those products.

This API has a client-side throttling limit of 10 requests per minute. If
you exceed this limit, wait 60 seconds and make the request again.

**Parameters:**

- `productIdentifiers` : `Array` — An array of objects identifying the products you want to rank. This array can include up to 50 items.  Each `ProductIdentifier` has:  - `Enum.InfoType`: Enum.InfoType   - Must be either `Enum.InfoType.GamePass` or     `Enum.InfoType.Product`. - `Id`: number   - The ID of the game pass or developer product.  ```lua local ProductIdentifier = { 	InfoType = Enum.InfoType.GamePass, 	Id = 123456 } ```

**Returns:**

- `Array` — The array of ranked items in a personalized order for the current user.  Each array has:  - `ProductIdentifier`: The corresponding ID from the input array. - `ProductInfo`: The standard product info dictionary returned by   `Class.MarketplaceService.GetProductInfoAsync|GetProductInfoAsync`.

### `MarketplaceService:RecommendTopProductsAsync`

```
RecommendTopProductsAsync(infoTypes: Array) -> Array
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields`

- Takes an array of `Enum.InfoType` and returns up to 50 items
  representing the products a user is most likely to engage with and
  purchase.

Takes an array of `Enum.InfoType` and returns up to 50 items representing
the products a user is most likely to engage with and purchase. If no
recommendations can be determined, the method returns an empty list.

This API has a client-side throttling limit of 5 requests per minute. If
you exceed this limit, wait 60 seconds and make the request again.

**Parameters:**

- `infoTypes` : `Array` — An array of `Enum.InfoType` values specifying the types of product to retrieve recommendations for.  Supported `InfoTypes`: `Enum.InfoType.GamePass`, `Enum.InfoType.Product`.  ```lua local infoTypes = { 	Enum.InfoType.GamePass, 	Enum.InfoType.Product } ```

**Returns:**

- `Array` — A ranked list of up to 50 items the user is most likely to engage with, based on the provided `InfoTypes`. If no recommendations can be determined, the method returns an empty list.

### `MarketplaceService:UserOwnsGamePassAsync`

```
UserOwnsGamePassAsync(userId: int64, gamePassId: int64) -> boolean
```

- security=`None` ; thread-safety=`Unsafe` ; tags=`Yields` ; capabilities=`AssetRead`

Returns true if the player with the given `Class.Player.UserId|UserId`
owns the pass with the given `gamePassId`.

Returns true if the user with the given `Class.Player.UserId|UserId` owns
the [pass](../../../production/monetization/passes.md) with the given
`gamePassId` (not to be confused with an asset ID). You can use this
method on both the client and the server.

#### Caching Behavior

The results of this function are cached so that repeated calls are
returned faster. When the
`Class.MarketplaceService.PromptGamePassPurchaseFinished|PromptGamePassPurchaseFinished`
event fires, the cache gets updated to reflect the latest ownership state
of the associated game pass.

If the user purchases a game pass outside of the experience while
remaining in the same session, the cache is eventually updated, but this
process might take several minutes to propagate.

When a user first enters a server after purchasing a game pass, this
functions always returns true.

**Parameters:**

- `userId` : `int64` — The `Class.Player.UserId|UserId` of the `Class.Player` whose inventory you're checking.
- `gamePassId` : `int64` — The pass ID you want to check for. Not to be confused with an asset ID.

**Returns:**

- `boolean` — 

## Events

### `MarketplaceService.PromptBulkPurchaseFinished`

```
PromptBulkPurchaseFinished(player: Instance, status: MarketplaceBulkPurchasePromptStatus, results: Dictionary)
```

- security=`None` ; capabilities=`PromptExternalPurchase`

Fires when a purchase prompt for bulk avatar items is closed.

This event fires when a purchase prompt for a bulk avatar items closes.
For example, when a user receives the purchase prompt and clicks
**Cancel**, or when they receive a success or error message and click
**OK**.

Note: This is not a trusted event from the client. To check if the user
owns the items purchased, use
`Class.MarketplaceService.PlayerOwnsAssetAsync` or
`Class.MarketplaceService.PlayerOwnsBundleAsync`.

**Parameters:**

- `player` : `Instance` — The `Class.Player` who received the prompt.
- `status` : `MarketplaceBulkPurchasePromptStatus` — The status of the bulk purchase.
- `results` : `Dictionary` — The table type containing the line items and their status in the following format:  ```lua {   RobuxSpent: number   Items: {     {       type: MarketplaceProductType,       id: string,       status: MarketplaceItemPurchaseStatus     },     ...   } } ```  Each line item contains the following pairs:  - `type`: The corresponding `Enum.MarketplaceProductType` (Enum). - `id`: The ID of the asset or bundle (string). - `status`: The `Enum.MarketplaceItemPurchaseStatus` of the purchase   (Enum)

### `MarketplaceService.PromptBundlePurchaseFinished`

```
PromptBundlePurchaseFinished(player: Instance, bundleId: int64, wasPurchased: boolean)
```

- security=`None` ; capabilities=`PromptExternalPurchase`

**Parameters:**

- `player` : `Instance` — 
- `bundleId` : `int64` — 
- `wasPurchased` : `boolean` — 

### `MarketplaceService.PromptGamePassPurchaseFinished`

```
PromptGamePassPurchaseFinished(player: Instance, gamePassId: int64, wasPurchased: boolean)
```

- security=`None` ; capabilities=`PromptExternalPurchase`

Fires when a purchase prompt for a pass is closed.

This event fires when a purchase prompt for a
[pass](../../../production/monetization/passes.md) closes. For example,
when a user receives the purchase prompt and clicks **Cancel**, or when
they receive a success or error message and click **OK**.

##### See also

- For repeatable **developer product** purchase prompts, use
  `Class.MarketplaceService.PromptProductPurchaseFinished|PromptProductPurchaseFinished`.
- For **affiliate gear sales** or other assets, use
  `Class.MarketplaceService.PromptPurchaseFinished|PromptPurchaseFinished`.
- For more information on saving and replicating user data like purchases
  and progress, see
  [Implementing player data and purchases](https://devforum.roblox.com/t/implementing-player-data-and-purchasing-systems/2839941).

**Parameters:**

- `player` : `Instance` — The `Class.Player` who received the prompt.
- `gamePassId` : `int64` — The ID number of the pass shown in the prompt. Not to be confused with an asset ID.
- `wasPurchased` : `boolean` — Indicates if the user pressed **OK** (true), **Cancel** (false) on the purchase prompt, or if the purchase prompt errored (false).  When `PromptGamePassPurchaseFinished` fires, it updates the cache used by `Class.MarketplaceService:UserOwnsGamePassAsync()|UserOwnsGamePassAsync()` to reflect the current ownership state.  `PromptGamePassPurchaseFinished` should only be listened to in a server script. When used on the server, values such as `wasPurchased` reflect the final outcome of the purchase attempt. When used in a local script, these values should not be relied on for validation or game logic.

### `MarketplaceService.PromptPremiumPurchaseFinished`

```
PromptPremiumPurchaseFinished()
```

- security=`None` ; capabilities=`PromptExternalPurchase`

Fires when a purchase prompt for Roblox Premium is closed.

This event fires when a purchase prompt for
[Roblox Premium](https://www.roblox.com/premium/membership) closes. For
example, when a user receives the purchase prompt and clicks **Cancel**,
or when they receive a success or error message and click **OK**.

##### See also

- `Class.MarketplaceService.PromptPremiumPurchase|PromptPremiumPurchase`
  to prompt a user to purchase Premium.
- `Class.Players.PlayerMembershipChanged|PlayerMembershipChanged`, which
  fires when the server recognizes that a user's membership has changed.

### `MarketplaceService.PromptProductPurchaseFinished`

```
PromptProductPurchaseFinished(userId: int64, productId: int64, isPurchased: boolean)
```

- security=`None` ; capabilities=`PromptExternalPurchase`

Fires when a purchase prompt for a developer product is closed. Do not use
this event to process purchases.

**IMPORTANT:** Do **not** use the `PromptProductPurchaseFinished` event to
process purchases; instead, use the
`Class.MarketplaceService.ProcessReceipt|ProcessReceipt` callback. The
firing of `PromptProductPurchaseFinished` does **not** mean that a user
has successfully purchased an item.

This event fires when a purchase prompt for a
[developer product](../../../production/monetization/developer-products.md)
closes. For example, when a user receives the purchase prompt and clicks
**Cancel**, or when they receive a success or error message and click
**OK**. The firing of this event does **not** mean that a user has
successfully purchased an item.

While you can use the `PromptProductPurchaseFinished` event to detect when
a user closes a purchase prompt, you should **not** use it to process
purchases because those purchases might still fail in the backend for
several reasons. For example, if a Roblox system is offline, or if the
product price has changed and the user now doesn't have enough Robux to
make the purchase. To process purchases, you must use
`Class.MarketplaceService.ProcessReceipt()|ProcessReceipt`. Using
`ProcessReceipt` allows you to confirm that the purchase has succeeded
before you grant the user the item they have purchased.

The `PromptProductPurchaseFinished` event fires with a `Player.UserId`
instead of a reference to the `Player` object.

##### See also

- `Class.MarketplaceService.PromptGamePassPurchaseFinished|PromptGamePassPurchaseFinished`
  to prompt a user to purchase a pass.
- `Class.MarketplaceService.PromptPurchaseFinished|PromptPurchaseFinished`
  to prompt a user to purchase affiliate gear or other assets.
- For more information on saving and replicating user data like purchases
  and progress, see
  [Implementing player data and purchases](https://devforum.roblox.com/t/implementing-player-data-and-purchasing-systems/2839941).

**Parameters:**

- `userId` : `int64` — The `Class.Player.UserId|UserId` of the user who received the developer product prompt.
- `productId` : `int64` — The ID number of the developer product shown in the prompt. Not to be confused with an asset ID.
- `isPurchased` : `boolean` — Indicates if the user pressed **OK** (true), **Cancel** (false) on the purchase prompt, or if the purchase prompt errored (false).  Do not use this parameter to process developer product purchases.

### `MarketplaceService.PromptPurchaseFinished`

```
PromptPurchaseFinished(player: Instance, assetId: int64, isPurchased: boolean)
```

- security=`None` ; capabilities=`PromptExternalPurchase`

Fires when a purchase prompt for an affiliate gear sale or other asset is
closed. Does **not** fire for developer product or pass prompts.

This event fires when a purchase prompt for an affiliate gear sale or
other asset closes. For example, when a user receives the purchase prompt
and clicks **Cancel**, or when they receive a success or error message and
click **OK**.

This event does not fire for
[developer product](../../../production/monetization/developer-products.md)
or [pass](../../../production/monetization/passes.md) prompts.

##### See also

- `Class.MarketplaceService.PromptGamePassPurchaseFinished|PromptGamePassPurchaseFinished`
  to prompt a user to purchase a pass.
- `Class.MarketplaceService.PromptProductPurchaseFinished|PromptProductPurchaseFinished`
  to prompt a user to purchase a developer product.
- For more information on saving and replicating user data like purchases
  and progress, see
  [Implementing player data and purchases](https://devforum.roblox.com/t/implementing-player-data-and-purchasing-systems/2839941).

**Parameters:**

- `player` : `Instance` — The `Class.Player` who received the prompt.
- `assetId` : `int64` — The asset ID of the item shown in the prompt.
- `isPurchased` : `boolean` — Indicates if the user pressed **OK** (true), **Cancel** (false) on the purchase prompt, or if the purchase prompt errored (false).  This might not accurately reflect if the purchase itself has been successfully processed.

### `MarketplaceService.PromptRobloxSubscriptionPurchaseFinished`

```
PromptRobloxSubscriptionPurchaseFinished(user: Player, didTryPurchasing: boolean)
```

- security=`None` ; capabilities=`PromptExternalPurchase`

Fires when a purchase prompt for Roblox Plus is closed.

This event fires when a purchase prompt for Roblox Plus closes. For
example, when a user receives the purchase prompt and clicks **Cancel**,
or when they receive a success or error message and click **OK**.

Note that this event firing does **not** guarantee the subscription was
successfully processed. Listen to `Class.Player.HasRobloxSubscription` via
`Class.Instance:GetPropertyChangedSignal()` on the server to confirm a
subscription change before granting rewards.

##### See also

- `Class.MarketplaceService.PromptRobloxSubscriptionPurchase|PromptRobloxSubscriptionPurchase`
  to prompt a user to purchase Roblox Plus.
- `Class.Player.HasRobloxSubscription`, which can be observed via
  `Class.Instance:GetPropertyChangedSignal()` to detect when a user's
  subscription status changes.

**Parameters:**

- `user` : `Player` — The `Class.Player` who received the prompt.
- `didTryPurchasing` : `boolean` — Whether the user attempted to purchase Roblox Plus.

### `MarketplaceService.PromptSubscriptionPurchaseFinished`

```
PromptSubscriptionPurchaseFinished(user: Player, subscriptionId: string, didTryPurchasing: boolean)
```

- security=`None` ; capabilities=`PromptExternalPurchase`

Fires when a purchase prompt for a subscription is closed.

This event fires when a purchase prompt for an affiliate gear sale or
other asset closes. For example, when a user receives the purchase prompt
and clicks **Cancel**, or when they receive a success or error message and
click **OK**.

##### See also

- `Class.MarketplaceService.PromptSubscriptionPurchase|PromptSubscriptionPurchase`
  to prompt a user to purchase a subscription.
- `Class.Players.UserSubscriptionStatusChanged|UserSubscriptionStatusChanged`,
  which fires when the server recognizes that a user's membership has
  changed.

**Parameters:**

- `user` : `Player` — The `Class.Player` who received the prompt.
- `subscriptionId` : `string` — The ID of the subscription with a status change.
- `didTryPurchasing` : `boolean` — Whether the user attempted to purchase the subscription.

## Notes / Deprecations

- Deprecated method `MarketplaceService:GetProductInfo`: This method has been superseded by
`Class.MarketplaceService.GetProductInfoAsync|GetProductInfoAsync()`.
- Deprecated method `MarketplaceService:PlayerOwnsAsset`: This method has been superseded by
`Class.MarketplaceService:PlayerOwnsAssetAsync()|PlayerOwnsAssetAsync()`.
- Deprecated method `MarketplaceService:PlayerOwnsBundle`: This method has been superseded by
`Class.MarketplaceService:PlayerOwnsBundleAsync()|PlayerOwnsBundleAsync()`.
- Deprecated method `MarketplaceService:PromptPremiumPurchase`: This method has been superseded by
`Class.MarketplaceService:PromptRobloxSubscriptionPurchase()|PromptRobloxSubscriptionPurchase()`.
- Method `MarketplaceService:GetDeveloperProductsAsync` yields (tag `Yields`).
- Method `MarketplaceService:GetProductInfo` yields (tag `Yields`).
- Method `MarketplaceService:GetProductInfoAsync` yields (tag `Yields`).
- Method `MarketplaceService:GetRobloxSubscriptionDetailsAsync` yields (tag `Yields`).
- Method `MarketplaceService:GetSubscriptionProductInfoAsync` yields (tag `Yields`).
- Method `MarketplaceService:GetUsersPriceLevelsAsync` yields (tag `Yields`).
- Method `MarketplaceService:GetUserSubscriptionDetailsAsync` yields (tag `Yields`).
- Method `MarketplaceService:GetUserSubscriptionPaymentHistoryAsync` yields (tag `Yields`).
- Method `MarketplaceService:GetUserSubscriptionStatusAsync` yields (tag `Yields`).
- Method `MarketplaceService:PlayerOwnsAsset` yields (tag `Yields`).
- Method `MarketplaceService:PlayerOwnsAssetAsync` yields (tag `Yields`).
- Method `MarketplaceService:PlayerOwnsBundle` yields (tag `Yields`).
- Method `MarketplaceService:PlayerOwnsBundleAsync` yields (tag `Yields`).
- Method `MarketplaceService:RankProductsAsync` yields (tag `Yields`).
- Method `MarketplaceService:RecommendTopProductsAsync` yields (tag `Yields`).
- Method `MarketplaceService:UserOwnsGamePassAsync` yields (tag `Yields`).

## Examples

Code samples referenced in the source YAML (stored as separate files in the Roblox creator-docs repo):

- MarketplaceService:GetDeveloperProductsAsync: MarketplaceService-GetDeveloperProductsAsync1
- MarketplaceService:GetProductInfo: MarketplaceService-GetProductInfo1
- MarketplaceService:GetProductInfoAsync: MarketplaceService-GetProductInfo1
- MarketplaceService:GetProductInfoAsync: MarketplaceService-GetProductInfo2
- MarketplaceService:GetRobloxSubscriptionDetailsAsync: MarketplaceService-GetRobloxSubscriptionDetailsAsync1
- MarketplaceService:GetUsersPriceLevelsAsync: MarketplaceService-GetUsersPriceLevelAsync
- MarketplaceService:GetUserSubscriptionPaymentHistoryAsync: MarketplaceService-GetUserSubscriptionPaymentHistoryAsync1
- MarketplaceService:GetUserSubscriptionStatusAsync: MarketplaceService-GetUserSubscriptionStatusAsync1
- MarketplaceService:PlayerOwnsAssetAsync: MarketplaceService-PlayerOwnsAsset1
- MarketplaceService:PlayerOwnsBundleAsync: MarketplaceService-PlayerOwnsBundle1
- MarketplaceService:PromptBulkPurchase: Prompt-Bulk-Purchase-Local
- MarketplaceService:PromptBulkPurchase: Prompt-Bulk-Purchase-Server
- MarketplaceService:PromptPremiumPurchase: prompt-premium-upsell
- MarketplaceService:PromptProductPurchase: MarketplaceService-PromptProductPurchase1
- MarketplaceService:PromptPurchase: MarketplaceService-PromptPurchase1
- MarketplaceService:PromptPurchase: market
- MarketplaceService:PromptRobloxSubscriptionPurchase: MarketplaceService-PromptRobloxSubscriptionPurchase
- MarketplaceService:RankProductsAsync: MarketplaceService-RankProductsSample
- MarketplaceService:RecommendTopProductsAsync: MarketplaceService-RecommendTopProductsSample
- MarketplaceService.PromptGamePassPurchaseFinished: handling-gamepass
- MarketplaceService.PromptPurchaseFinished: MarketplaceService-PromptPurchaseFinished1
- MarketplaceService.PromptRobloxSubscriptionPurchaseFinished: MarketplaceService-PromptRobloxSubscriptionPurchaseFinished

Full code samples were not embedded in this capture; see the source repo for the verbatim Luau code.

## Source

- Official docs page: https://create.roblox.com/docs/reference/engine/classes/MarketplaceService
- Authoritative YAML: https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/MarketplaceService.yaml
- Captured: 2026-04-16
