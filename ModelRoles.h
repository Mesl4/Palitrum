#pragma once
#include <Qt>

enum SharedRoles {
    IdRole = Qt::UserRole + 1,
    NameRole,
    ModifiedDateRole,
    ColorsRole,
    ProjectIdRole,
    PaletteCountRole,
    DescRole,
    EditableRole,
    PopularityRole
};
