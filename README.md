# CoreDataInCode
## What is this?
This is an example of how to use Core Data without using Xcode's data model design tool. The Core Data models and migrations in this project are created completely in code.

## Why?
Several reasons:

1. I can. And shouldn't that be enough?

2. Apple explicitly mentions that it's possible in the [Core Data Programming Guide][CDPG], but doesn't provide any examples.

3. To better understand Core Data models and migrations.

4. Writing models in code, while it takes more time initially, is easier to diff. That means easier merging, clearer changeset history, and potentially saved time down the road.

5. On iOS, app writers are limited to static libraries for reusing code between apps. That complicates the bundling of compiled object models. By writing models in code, they are included directly in the .a file.

[CDPG]: http://developer.apple.com/library/mac/documentation/cocoa/conceptual/coredata/Articles/cdBasics.html#//apple_ref/doc/uid/TP40001650-207332-TPXREF151

## Notes
* I stopped short of making this an actual working app. After upgrading to the latest model, you won't be able to set the source for any recipes. I focused on the models and migrations.
