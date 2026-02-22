import { readOnly } from "@ember/object/computed";
import { service } from "@ember/service";
import { apiInitializer } from "discourse/lib/api";
import TopicListThumbnail from "../components/topic-list-thumbnail";

// Wrapper that renders the thumbnail inside a <td> for use as a table column
const TopicListThumbnailCell = <template>
  <td class="topic-thumbnail-cell">
    <TopicListThumbnail @topic={{@topic}} />
  </td>
</template>;

export default apiInitializer((api) => {
  const ttService = api.container.lookup("service:topic-thumbnails");

  api.registerValueTransformer("topic-list-class", ({ value }) => {
    if (ttService.displayMinimalGrid) {
      value.push("topic-thumbnails-minimal");
    } else if (ttService.displayGrid) {
      value.push("topic-thumbnails-grid");
    } else if (ttService.displayList) {
      value.push("topic-thumbnails-list");
    } else if (ttService.displayMasonry) {
      value.push("topic-thumbnails-masonry");
    } else if (ttService.displayBlogStyle) {
      value.push("topic-thumbnails-blog-style-grid");
    }
    return value;
  });

  api.registerValueTransformer("topic-list-columns", ({ value: columns }) => {
    if (ttService.enabledForRoute) {
      if (ttService.displayList) {
        // List mode: add thumbnail as the last column (right side) wrapped in <td>
        columns.add("thumbnail", { item: TopicListThumbnailCell });
      } else {
        // Grid/masonry/minimal modes: add thumbnail before the topic column
        columns.add(
          "thumbnail",
          { item: TopicListThumbnail },
          { before: "topic" }
        );
      }
    }
    return columns;
  });

  api.registerValueTransformer("topic-list-item-mobile-layout", ({ value }) => {
    if (ttService.enabledForRoute && !ttService.displayList) {
      // Force the desktop layout
      return false;
    }
    return value;
  });

  api.registerValueTransformer(
    "topic-list-item-class",
    ({ value, context: { index } }) => {
      if (ttService.displayMasonry) {
        value.push(`masonry-${index}`);
      }
      return value;
    }
  );

  const siteSettings = api.container.lookup("service:site-settings");
  if (settings.docs_thumbnail_mode !== "none" && siteSettings.docs_enabled) {
    api.modifyClass("component:docs-topic-list", {
      pluginId: "topic-thumbnails",
      topicThumbnailsService: service("topic-thumbnails"),
      classNameBindings: [
        "isMinimalGrid:topic-thumbnails-minimal",
        "isThumbnailGrid:topic-thumbnails-grid",
        "isThumbnailList:topic-thumbnails-list",
        "isMasonryList:topic-thumbnails-masonry",
        "isBlogStyleGrid:topic-thumbnails-blog-style-grid",
      ],
      isMinimalGrid: readOnly("topicThumbnailsService.displayMinimalGrid"),
      isThumbnailGrid: readOnly("topicThumbnailsService.displayGrid"),
      isThumbnailList: readOnly("topicThumbnailsService.displayList"),
      isMasonryList: readOnly("topicThumbnailsService.displayMasonry"),
      isBlogStyleGrid: readOnly("topicThumbnailsService.displayBlogStyle"),
    });
  }
});
